#import "BirdsListViewController.h"
#import "BIrd.h"
#import "BirdDetailsViewController.h"
#import "AppDelegate.h"
#import "AddBirdViewController.h"
#import "BirdCell.h"

@interface BirdsListViewController ()

@end

@implementation BirdsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Birdy list";
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    self.birds = [delegate.data allBirds];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewBird)];
    self.navigationItem.rightBarButtonItem = addButton;
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
    return self.birds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentyfier = @"birdCell";
    
    BirdCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentyfier];
    
    if (cell == NULL) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CellCustomView" owner:self options:nil] objectAtIndex:0];
        
        
        
        // cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:(cellIdentyfier)];
    }
    
    cell.birdCellNameLabel.text = [[self.birds objectAtIndex:indexPath.row] name];
    cell.birdCellLatinNameLabel.text = [[self.birds objectAtIndex:indexPath.row] latinName];
    NSString *imageUrl = [[self.birds objectAtIndex:indexPath.row] pictureUrl];
    cell.birdCellImageView.image = [UIImage imageNamed:imageUrl];
    cell.birdCellImageView.contentMode = UIViewContentModeScaleAspectFit;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    Bird *currentBird = [self.birds objectAtIndex:indexPath.row];
    NSString *detailsSb = @"detailsStoryBoard";
    BirdDetailsViewController *detailsController = [self.storyboard instantiateViewControllerWithIdentifier:detailsSb];
    detailsController.bird = currentBird;
    [self.navigationController pushViewController:detailsController animated:YES];
}

- (void)insertNewBird {
    if (!self.birds) {
        self.birds = [[NSMutableArray alloc] init];
    }
    
    NSString *detailsSb = @"addPhoneStoryBoard";
    AddBirdViewController *addBirdController = [self.storyboard instantiateViewControllerWithIdentifier:detailsSb];
    [self.navigationController pushViewController:addBirdController animated:YES];

}
@end
