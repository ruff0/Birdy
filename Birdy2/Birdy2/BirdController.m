#import "BirdController.h"
#import "Birdy2-Swift.h"
#import "Coordinates.h"

@interface BirdController ()

- (IBAction)seeLocations:(id)sender;
@property (strong, nonatomic) NSMutableArray *locations;

- (IBAction)birdImagepinch:(UIPinchGestureRecognizer *)sender;

- (IBAction)birdImagePan:(UIPanGestureRecognizer *)sender;

@end

@implementation BirdController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.birdDescription.scrollsToTop = YES;
    
    self.locations = [NSMutableArray array];
    if (self.bird.observedPositionsCoordinates){
        self.locations = self.bird.observedPositionsCoordinates;
    } else {
        for (NSDictionary *location in self.bird.observedPositionsFromDb){
            Coordinates *currentPositions = [Coordinates coordinatesWithDict: location];
            [self.locations addObject:currentPositions];
        }
    }
    
    self.birdImageView.userInteractionEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

- (IBAction)seeLocations:(id)sender {
    LocationsViewController *locationsController = [[LocationsViewController alloc]init];
    locationsController.locations = self.locations;
    [self.navigationController pushViewController:locationsController animated:YES];
}

- (IBAction)birdIePinch:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged) {
        CGFloat currentScale = self.birdImageView.frame.size.width / self.birdImageView.bounds.size.width;
        CGFloat newScale = currentScale * sender.scale;
        
        if (newScale < 0.3) {
            newScale = 0.3;
        }
        if (newScale > 3) {
             newScale = 3;
        }
        
        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
        self.birdImageView.transform = transform;
        sender.scale = 1;
    }
}

- (IBAction)birdImagepinch:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged) {
        CGFloat currentScale = self.birdImageView.frame.size.width / self.birdImageView.bounds.size.width;
        CGFloat newScale = currentScale * sender.scale;
        
        if (newScale < 0.3) {
            newScale = 0.3;
        }
        if (newScale > 3) {
            newScale = 3;
        }
        
        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
        self.birdImageView.transform = transform;
        sender.scale = 1;
    }
}

- (IBAction)birdImagePan:(UIPanGestureRecognizer *)sender {
    UIGestureRecognizerState state = [sender state];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [sender translationInView:sender.view];
        CGAffineTransform translate = CGAffineTransformTranslate(sender.view.transform, translation.x, translation.y);
        self.birdImageView.transform = translate;
        [sender setTranslation:CGPointZero inView:sender.view];
    }
}


@end
