#import "BirdsListViewController.h"
#import "BIrd.h"
#import "BirdAndDictionary.h"
#import "BirdsContentController.h"
#import "AppDelegate.h"
#import "AddBirdViewController.h"
#import "BirdCell.h"
#import "HttpData.h"

@interface BirdsListViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (strong, nonatomic) HttpData *http;

@end

@implementation BirdsListViewController
{
    NSString *_url;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    self.searchResults = [self.birds mutableCopy];
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
    NSString *imageUrl = [[self.searchResults objectAtIndex:indexPath.row] pictureUrl];
    cell.birdCellImageView.image = [UIImage imageNamed:imageUrl];
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

-(void) loadBirds {
    __weak id weakSelf = self;
    
    [self.http getFrom:_url headers:nil withCompletionHandler:^(NSDictionary * dict, NSError *err) {
        if(err){
            NSString *errorMsg = [err description];
            NSLog(errorMsg);
            return;
        }
        
        NSMutableArray *dataResultBirds = [NSMutableArray array];
        NSInteger i = 0;
        for (NSDictionary *dictBird in dict){
            i ++;
            NSString *pic = [NSString stringWithFormat:@"%d", i];
            [dataResultBirds addObject:[Bird birdWithDict: dictBird andWithPicture: pic]];
        }
        self.birds = dataResultBirds;
        self.searchResults = dataResultBirds;
     
        dispatch_async(dispatch_get_main_queue(), ^{
            [[weakSelf tableView] reloadData];
        });
    }];
}

- (void)insertNewBird {
    if (!self.birds) {
        self.birds = [[NSMutableArray alloc] init];
    }
    
    NSString *detailsSb = @"addBirdStoryBoard";
    AddBirdViewController *addBirdController = [self.storyboard instantiateViewControllerWithIdentifier:detailsSb];
    [self.navigationController pushViewController:addBirdController animated:YES];
}

@end
