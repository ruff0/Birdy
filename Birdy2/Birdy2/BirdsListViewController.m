#import "BirdsListViewController.h"
#import "BIrd.h"
#import "BirdDetailsViewController.h"
#import "BirdsContentController.h"
#import "AppDelegate.h"
#import "AddBirdViewController.h"
#import "BirdCell.h"

@interface BirdsListViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

// working with JSON (file in this case)
// NSString *path = [[NSBundle mainBundle] pathForResource:@"airlineData" ofType:@"json"];
// NSData *data = [NSData dataWithContentsOfFile:path];
// NSError *error;
// NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
// self.airlines = dict[@"airlines"];

@implementation BirdsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Birdy list";
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    self.birds = [delegate.data allBirds];
    self.searchResults = [self.birds mutableCopy];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewBird)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    self.birds = [delegate.data allBirds];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchResults != nil && self.searchResults.count > 0) {
        return self.searchResults.count;
    }
    
    return self.birds.count;
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
    
    Bird *currentBird = [self.searchResults objectAtIndex:indexPath.row];
    
    NSString *detailsSb = @"birdsDetailsStoryBoard";
    BirdsContentController *detailsController = [self.storyboard instantiateViewControllerWithIdentifier:detailsSb];
    detailsController.birdsArray = self.searchResults;
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
            
            self.searchResults = searchResults;
        }
    }
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
