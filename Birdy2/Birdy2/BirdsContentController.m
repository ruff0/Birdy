#import "BirdsContentController.h"
#import "BirdController.h"
#import "HttpData.h"
#import "Coordinates.h"
#import <CoreLocation/CoreLocation.h>

@interface BirdsContentController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (strong, nonatomic) IBOutlet UIPageControl *pageCOntrol;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) HttpData *http;

@property (weak, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSString* latitude;
@property (strong, nonatomic) NSString* longitude;

@end

@implementation BirdsContentController
{
    NSString *_baseUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCoordinates)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.http = [HttpData httpData];
    _baseUrl = @"https://protected-falls-94776.herokuapp.com/api/birds/coordinates/";
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUInteger numberPages = self.birdsArray.count;
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    self.scrollView.frame = self.view.bounds;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake((self.scrollView.frame.size.width + 8) * numberPages, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageCOntrol.numberOfPages = numberPages;
    self.pageCOntrol.currentPage = 0;
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= self.birdsArray.count) {
        return;
    }

    BirdController *controller = [self.viewControllers objectAtIndex:page];
    Bird *currentBird = [self.birdsArray objectAtIndex: page];
    
    if ((NSNull *)controller == [NSNull null]) {
        NSString *birdStoryBoard = @"bird";        
        controller = [self.storyboard instantiateViewControllerWithIdentifier:birdStoryBoard];
        controller.bird = currentBird;
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page >= self.birdsArray.count) {
        return;
    }
    self.pageCOntrol.currentPage = page;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    for (UIView *view in self.scrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSUInteger numPages = self.birdsArray.count;
    
    self.scrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numPages, CGRectGetHeight(self.scrollView.frame));
    
    self.viewControllers = nil;
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numPages; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // Load an another view which will be for horizontal devices! Simply change the UIView of the controller!!!!
    [self loadScrollViewWithPage:self.pageCOntrol.currentPage - 1];
    [self loadScrollViewWithPage:self.pageCOntrol.currentPage];
    [self loadScrollViewWithPage:self.pageCOntrol.currentPage + 1];
    [self gotoPage:NO];
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageCOntrol.currentPage;
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)pageChanged:(id)sender {
    [self gotoPage:YES];
}

- (void) addCoordinates {
    self.alertController = [UIAlertController alertControllerWithTitle:@"Adding new coordinates" message:@"You are about to add your current location as a place where this bird has been observed. Do you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
    
    __weak id weakSelf = self;
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        Bird *currentBird = [self.birdsArray objectAtIndex:self.pageCOntrol.currentPage];
        NSString *currentBirdId = [currentBird id];
        NSDictionary *header = [[NSDictionary alloc] initWithObjectsAndKeys:@"application/json", @"content-type", nil];
        NSString *url = [_baseUrl stringByAppendingString:currentBirdId];
        NSDictionary *currentCoordinates = [[NSDictionary alloc]initWithObjectsAndKeys:self.latitude, @"latitude", self.longitude, @"longitude", nil];
        
        [[weakSelf http] putAt:url withBody:currentCoordinates headers:header andCompletionHandler:^(NSDictionary *dict, NSError *err) {

            NSInteger responseStatusNumber = 200;
            if (![dict isKindOfClass:[NSArray class]]) {
                if ([dict objectForKey:@"status"]) {
                    responseStatusNumber = [[dict objectForKey:@"status"] integerValue];
                }
            }
            
            if(err || (responseStatusNumber >= 400)){
                dispatch_async(dispatch_get_main_queue(), ^{
                   UIAlertController *failAlertController = [UIAlertController alertControllerWithTitle:@"Adding coordinates failed" message:@"Network access or connectivity problems terminated the action." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                    [failAlertController addAction:actionOk];
                    [weakSelf presentViewController:failAlertController animated:YES completion:nil];
                });
                return;
            }
            
            Coordinates *newCoordinates = [Coordinates CoordinatesWithLatitude:self.latitude andWithLongitude:self.longitude];
            [currentBird.observedPositionsCoordinates addObject:newCoordinates];
            
            /*NSMutableArray *positions = [NSMutableArray array];
            if (currentBird.observedPositionsCoordinates){
                positions = currentBird.observedPositionsCoordinates;
            } else {
                for (NSDictionary *location in currentBird.observedPositionsFromDb){
                    Coordinates *currentPositions = [Coordinates coordinatesWithDict: location];
                    [positions addObject:currentPositions];
                }
            }
            
            [positions addObject:newCoordinates];
            currentBird.observedPositionsCoordinates = positions;*/
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *successAlertController = [UIAlertController alertControllerWithTitle:@"Adding coordinates done" message:@"Your current coordinates have been added to Birdy database." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [successAlertController addAction:actionOk];
                [weakSelf presentViewController:successAlertController animated:YES completion:nil];
            });
            return;
        }];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleCancel handler: nil];
    
    [self.alertController addAction:cancelAction];
    [self.alertController addAction:okAction];
    
    [self presentViewController:self.alertController animated:YES completion:nil];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    if (currentLocation != nil) {
        self.longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
}

@end


