#import "BirdsListViewController.h"
#import "BIrd.h"
#import "BirdAndDictionary.h"
#import "BirdsContentController.h"
#import "AppDelegate.h"
#import "AddBirdViewController.h"
#import "BirdCell.h"
#import "HttpData.h"
#import <CoreData/CoreData.h>
#import "Coordinates.h"

@interface BirdsListViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (strong, nonatomic) HttpData *http;

@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

@end

@implementation BirdsListViewController
{
    NSString *_url;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(145, 190, 20,20)];
    [self.loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingIndicator setHidesWhenStopped:YES];
    [self.view addSubview:self.loadingIndicator];
    
    self.title = @"Birdy list";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewBird)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    
    _url = @"https://protected-falls-94776.herokuapp.com/api/birds";
    self.http = [HttpData httpData];
    [self loadBirds];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getBirdsFromCd];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentyfier = @"birdCell";
    BirdCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentyfier];
    
    if (cell == NULL) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CellCustomView" owner:self options:nil] objectAtIndex:0];
    }
    
    cell.birdCellNameLabel.text = [[self.searchResults objectAtIndex:indexPath.row] name];
    cell.birdCellLatinNameLabel.text = [[self.searchResults objectAtIndex:indexPath.row] latinName];
    
    NSString *pic = [[self.searchResults objectAtIndex:indexPath.row] picture];
    NSData *pictureData = [[NSData alloc]initWithBase64EncodedString:pic options:NSDataBase64DecodingIgnoreUnknownCharacters];
    cell.birdCellImageView.image = [UIImage imageWithData:pictureData];
    cell.birdCellImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSString *detailsSb = @"birdsDetailsStoryBoard";
    BirdsContentController *detailsController = [self.storyboard instantiateViewControllerWithIdentifier:detailsSb];
    
    detailsController.birdsArray = [[NSMutableArray alloc] init];
    NSInteger numberOfResultBirds = self.searchResults.count;
    for (NSInteger i = 0; i < numberOfResultBirds; i++) {
        if (i + indexPath.row < numberOfResultBirds) {
            [detailsController.birdsArray addObject: [self.searchResults objectAtIndex:indexPath.row + i]];
        } else {
            [detailsController.birdsArray addObject: [self.searchResults objectAtIndex:indexPath.row + i - numberOfResultBirds]];
        }
    }
    
    [self.navigationController pushViewController:detailsController animated:YES];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = self.searchController.searchBar.text;
    [self updateFilteredContentForBirdName:searchString];
    [self.tableView reloadData];
}

- (void)updateFilteredContentForBirdName:(NSString *)newName {
    if (newName == nil || [newName length] == 0) {
        self.searchResults = [self.birds mutableCopy];
    } else {
        NSMutableArray *searchResults = [[NSMutableArray alloc] init];
        for (Bird *bird in self.birds) {
            if ([[bird.name lowercaseString] containsString:[newName lowercaseString]]) {
                [searchResults addObject:bird];
            }
        }
        self.searchResults = searchResults;
    }
}

-(NSManagedObjectContext*) managedContext {
     return((AppDelegate*) [UIApplication sharedApplication].delegate).managedObjectContext;
}

-(void) loadBirds {
    [self getBirdsFromCd];
    if (!self.searchResults || self.searchResults.count == 0) {
        [self getDataFromServer];
    } else {
        [self updateDataFromServer];
    }
}

- (void) getBirdsFromCd {
    // Here I should get the birds from core data
    NSError *fetchError = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Bird"];
    NSArray *birdsFromCoreData = [self.managedContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        NSLog(@"Error fetching birdies from core data: %@\n%@", [fetchError localizedDescription], [fetchError userInfo]);
        return;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (NSManagedObject *cdBirdy in birdsFromCoreData) {
        NSString *id = [cdBirdy valueForKey:@"id"];
        NSString *name = [cdBirdy valueForKey:@"name"];
        NSString *latinName = [cdBirdy valueForKey:@"latinName"];
        NSString *description = [cdBirdy valueForKey:@"descr"];
        NSString *picture = [cdBirdy valueForKey:@"picture"];
        NSMutableArray *observedPositions = [cdBirdy valueForKey:@"observedPositions"];
        
        Bird *currentBird = [Bird BirdWithId:id withName:name withLatinName:latinName withPic:picture withDescription:description andWithPositions:observedPositions];
        
        [result addObject:currentBird];
    };
    
    self.searchResults = result;
    [self.tableView reloadData];
}


-(void) getDataFromServer {
    // Here I should get the data from server
    __weak id weakSelf = self;
    [self.loadingIndicator startAnimating];
    
    [self.http getFrom:_url headers:nil withCompletionHandler:^(NSDictionary * dict, NSError *err) {
        NSInteger responseStatusNumber = 200;
        if (![dict isKindOfClass:[NSArray class]]) {
            if ([dict objectForKey:@"status"]) {
                responseStatusNumber = [[dict objectForKey:@"status"] integerValue];
            }
        }
        
        if(err || (responseStatusNumber >= 400)){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *failAlertController = [UIAlertController alertControllerWithTitle:@"Loading birdies failed" message:@"Network access or connectivity problems terminated the action." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [failAlertController addAction:actionOk];
                [weakSelf presentViewController:failAlertController animated:YES completion:nil];
                [[weakSelf loadingIndicator] stopAnimating];
            });
            return;
        }
        
        [self saveNewLastUpdatedDate];
        NSMutableArray *dataResultBirds = [NSMutableArray array];
        for (NSDictionary *dictBird in dict){
            Bird *currentBird = [Bird birdWithDict: dictBird];
            [dataResultBirds addObject: currentBird];
        }
        
        [weakSelf saveBirdsToCd:dataResultBirds];
        [weakSelf getBirdsFromCd];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[weakSelf tableView] reloadData];
            [[weakSelf loadingIndicator] stopAnimating];
        });
    }];
}

- (void) saveBirdsToCd:(NSMutableArray*)resultsBirds {
    NSEntityDescription *birdDescription = [NSEntityDescription entityForName:@"Bird" inManagedObjectContext:self.managedContext];
    NSEntityDescription *coordinatesDescription = [NSEntityDescription entityForName:@"Coordinates" inManagedObjectContext:self.managedContext];
    
    for (Bird *birdy in resultsBirds){
        NSManagedObject *theCurrentBird = [[NSManagedObject alloc] initWithEntity:birdDescription insertIntoManagedObjectContext:self.managedContext];
        [theCurrentBird setValue:birdy.id forKey:@"id"];
        [theCurrentBird setValue:birdy.name forKey:@"name"];
        [theCurrentBird setValue:birdy.latinName forKey:@"latinName"];
        [theCurrentBird setValue:birdy.descr forKey:@"descr"];
        [theCurrentBird setValue:birdy.picture forKey:@"picture"];
        
        for (NSDictionary *location in birdy.observedPositionsFromDb){
            Coordinates *currentPositions = [Coordinates coordinatesWithDict: location];
            NSManagedObject *theCurrentCoordinates = [[NSManagedObject alloc] initWithEntity:coordinatesDescription insertIntoManagedObjectContext:self.managedContext];
            [theCurrentCoordinates setValue:currentPositions.latitude forKey:@"latitude"];
            [theCurrentCoordinates setValue:currentPositions.longitude forKey:@"longitude"];
            [theCurrentCoordinates setValue:birdy.id forKey:@"birdyId"];
            [theCurrentCoordinates setValue:theCurrentBird forKey:@"bird"];
        }
    }
    
    NSError *coreDataErr;
    if (![self.managedContext save:&coreDataErr]) {
        NSLog(@"Error saving birdies to core data: %@\n%@", [coreDataErr localizedDescription], [coreDataErr userInfo]);
        return;
    }
}

- (void) updateDataFromServer {
    // Here I should get the updated data from server
    __weak id weakSelf = self;
    
    NSString *lastUpdatedDate = [self getLastUpdatedDate];
    NSString *url = [[_url stringByAppendingString:@"/new/"] stringByAppendingString:lastUpdatedDate];
    
    [self.http getFrom:url headers:nil withCompletionHandler:^(NSDictionary * dict, NSError *err) {
        NSInteger responseStatusNumber = 200;
        if (![dict isKindOfClass:[NSArray class]]) {
            if ([dict objectForKey:@"status"]) {
                responseStatusNumber = [[dict objectForKey:@"status"] integerValue];
            }
        }
        
        if(err || (responseStatusNumber >= 400)){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *failAlertController = [UIAlertController alertControllerWithTitle:@"Updating birdies failed" message:@"Network access or connectivity problems terminated the action." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [failAlertController addAction:actionOk];
                [weakSelf presentViewController:failAlertController animated:YES completion:nil];
            });
            return;
        }
        
        [self saveNewLastUpdatedDate];
        NSDictionary *birdsResults = [dict objectForKey:@"birds"];
        NSDictionary *coordinatesResults = [dict objectForKey:@"coordinates"];
        
        if (coordinatesResults) {
            NSMutableArray *dataResultCoordinates = [NSMutableArray array];
            for (NSDictionary *dictCoordinate in coordinatesResults){
                Coordinates *currentCoordinates = [Coordinates coordinatesWithDictAndBirdId: dictCoordinate];
                [dataResultCoordinates addObject: currentCoordinates];
            }
            
            [self saveCoordinatesToCd:dataResultCoordinates];
        }
        
        if (birdsResults) {
            NSMutableArray *dataResultBirds = [NSMutableArray array];
            for (NSDictionary *dictBird in birdsResults){
                Bird *currentBird = [Bird birdWithDict: dictBird];
                [dataResultBirds addObject: currentBird];
            }
            [self saveBirdsToCd:dataResultBirds];
            [self getBirdsFromCd];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[weakSelf tableView] reloadData];
            });
        }
    }];
}

-(void) saveCoordinatesToCd:(NSMutableArray*) newCoordinates {
    NSEntityDescription *coordinatesDescription = [NSEntityDescription entityForName:@"Coordinates" inManagedObjectContext:self.managedContext];
    
    for (Coordinates *coords in newCoordinates){
        NSManagedObject *theCurrentCoordinates = [[NSManagedObject alloc] initWithEntity:coordinatesDescription insertIntoManagedObjectContext:self.managedContext];
        [theCurrentCoordinates setValue:coords.latitude forKey:@"latitude"];
        [theCurrentCoordinates setValue:coords.longitude forKey:@"longitude"];
        [theCurrentCoordinates setValue:coords.birdyId forKey:@"birdyId"];
    }
}

-(void) saveNewLastUpdatedDate {
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *stringDate = [dateFormatter stringFromDate:[NSDate date]];
    [plistDict setObject:stringDate forKey:@"oupdatedOn"];
    
    NSString *plistPath = [self getPlistFilePath];
    [plistDict writeToFile:plistPath atomically:YES];
}

-(NSString*) getLastUpdatedDate {
    NSString *plistPath = [self getPlistFilePath];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *lastUpdatedDate = [plistDict objectForKey:@"oupdatedOn"];
    return lastUpdatedDate;
}

-(NSString*) getPlistFilePath {
    NSArray *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [docDir objectAtIndex: 0];
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"LastUpdatedOn.plist"];
    
    NSError *err = nil;
    NSFileManager *fManager = [NSFileManager defaultManager];
    
    if(![fManager fileExistsAtPath:plistPath])
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"LastUpdatedOn" ofType:@"plist"];
        [fManager copyItemAtPath:bundlePath toPath:plistPath error:&err];
    }
    
    return plistPath;
}

- (void)insertNewBird {
    NSString *detailsSb = @"addBirdStoryBoard";
    AddBirdViewController *addBirdController = [self.storyboard instantiateViewControllerWithIdentifier:detailsSb];
    [self.navigationController pushViewController:addBirdController animated:YES];
}


@end




/*__weak id weakSelf = self;

[self.http getFrom:_url headers:nil withCompletionHandler:^(NSDictionary * dict, NSError *err) {
    NSInteger responseStatusNumber = 200;
    if (![dict isKindOfClass:[NSArray class]]) {
        if ([dict objectForKey:@"status"]) {
            responseStatusNumber = [[dict objectForKey:@"status"] integerValue];
        }
    }
    
    if(err || (responseStatusNumber >= 400)){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *failAlertController = [UIAlertController alertControllerWithTitle:@"Loading birdies failed" message:@"Network access or connectivity problems terminated the action." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [failAlertController addAction:actionOk];
            [weakSelf presentViewController:failAlertController animated:YES completion:nil];
        });
        return;
    }
    
    NSMutableArray *dataResultBirds = [NSMutableArray array];
    for (NSDictionary *dictBird in dict){
        Bird *currentBird = [Bird birdWithDict: dictBird];
        [dataResultBirds addObject: currentBird];
    }
    
    
    // Load results in coreData
    
    
    NSEntityDescription *birdDescription = [NSEntityDescription entityForName:@"Bird" inManagedObjectContext:managedContext];
    NSEntityDescription *coordinatesDescription = [NSEntityDescription entityForName:@"Coordinates" inManagedObjectContext:managedContext];
    
    
    
    for (Bird *birdy in dataResultBirds){
        NSManagedObject *theCurrentBird = [[NSManagedObject alloc] initWithEntity:birdDescription insertIntoManagedObjectContext:managedContext];
        [theCurrentBird setValue:birdy.id forKey:@"id"];
        [theCurrentBird setValue:birdy.name forKey:@"name"];
        [theCurrentBird setValue:birdy.latinName forKey:@"latinName"];
        [theCurrentBird setValue:birdy.descr forKey:@"descr"];
        [theCurrentBird setValue:birdy.picture forKey:@"picture"];
        
        for (NSDictionary *location in birdy.observedPositionsFromDb){
            Coordinates *currentPositions = [Coordinates coordinatesWithDict: location];
            NSManagedObject *theCurrentCoordinates = [[NSManagedObject alloc] initWithEntity:coordinatesDescription insertIntoManagedObjectContext:managedContext];
            [theCurrentCoordinates setValue:currentPositions.latitude forKey:@"latitude"];
            [theCurrentCoordinates setValue:currentPositions.longitude forKey:@"longitude"];
            [theCurrentCoordinates setValue:birdy.id forKey:@"birdyId"];
            [theCurrentCoordinates setValue:theCurrentBird forKey:@"bird"];
        }
    }
    
    NSError *coreDataErr;
    if (![managedContext save:&coreDataErr]) {
        NSLog(@"Error saving birdies to core data: %@\n%@", [coreDataErr localizedDescription], [coreDataErr userInfo]);
        return;
    }
    
    
    // Retrieving data back
    NSError *fetchError = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Bird"];
    NSArray *birdsFromCoreData = [managedContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        NSLog(@"Error fetching birdies from core data: %@\n%@", [fetchError localizedDescription], [fetchError userInfo]);
        return;
    }
    
    NSError *fetchErrorCoordinates = nil;
    NSFetchRequest *coordinatesRequest = [[NSFetchRequest alloc]initWithEntityName:@"Coordinates"];
    NSArray *coordinatesFromCoreData = [managedContext executeFetchRequest:coordinatesRequest error:&fetchErrorCoordinates];
    if (fetchErrorCoordinates) {
        NSLog(@"Error fetching birdies from core data: %@\n%@", [fetchErrorCoordinates localizedDescription], [fetchErrorCoordinates userInfo]);
        return;
    }
    
    NSMutableArray *coordinates = [[NSMutableArray alloc]init];
    for (NSManagedObject *cdCoordinates in coordinatesFromCoreData) {
        NSString *latitude = [cdCoordinates valueForKey:@"latitude"];
        NSString *longitude = [cdCoordinates valueForKey:@"longitude"];
        
        Coordinates *currentCoordinates = [Coordinates CoordinatesWithLatitude:latitude andWithLongitude:longitude];
        
        [coordinates addObject:currentCoordinates];
    };
    
    for (NSManagedObject *cdBirdy in birdsFromCoreData) {
        NSString *id = [cdBirdy valueForKey:@"id"];
        NSString *name = [cdBirdy valueForKey:@"name"];
        NSString *latinName = [cdBirdy valueForKey:@"latinName"];
        NSString *description = [cdBirdy valueForKey:@"descr"];
        NSString *picture = [cdBirdy valueForKey:@"picture"];
        NSMutableArray *observedPositions = [cdBirdy valueForKey:@"observedPositions"];
        
        Bird *currentBird = [Bird BirdWithId:id withName:name withLatinName:latinName withPic:picture withDescription:description andWithPositions:observedPositions];
        
        [self.birds addObject:currentBird];
    };
    
    // !!! I should copy this!!!
    // self.searchResults = dataResultBirds;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[weakSelf tableView] reloadData];
        [[weakSelf loadingIndicator] stopAnimating];
    });
}];*/

