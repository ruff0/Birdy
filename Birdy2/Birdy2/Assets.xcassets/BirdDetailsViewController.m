#import "BirdDetailsViewController.h"
#import "BirdsListViewController.h"
#import "AppDelegate.h"

@interface BirdDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *birdNameLable;

@property (weak, nonatomic) IBOutlet UILabel *birdLatinNameLable;

@property (weak, nonatomic) IBOutlet UIImageView *birdImageView;

@property (weak, nonatomic) IBOutlet UILabel *birdDescriptionLable;

@end

@implementation BirdDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.birdNameLable.text = self.bird.name;
    self.birdLatinNameLable.text = self.bird.latinName;
    self.birdDescriptionLable.text = self.bird.description;
    NSString *imageUrl = self.bird.pictureUrl;
    self.birdImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.birdImageView.image = [UIImage imageNamed:imageUrl];
    
    self.title = self.bird.name;
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Birdy" style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(goBirdyHome:)];
    self.navigationItem.rightBarButtonItem = homeButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goBirdyHome:(UIButton *)sender
{
    // Use this to change the viewController!!!
    NSString *homeStoryboardId = @"homeScreen";
    BirdsListViewController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:homeStoryboardId];
    [self.navigationController pushViewController:homeController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
