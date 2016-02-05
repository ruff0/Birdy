#import "BirdController.h"
#import "Birdy2-Swift.h"
#import "Coordinates.h"

@interface BirdController ()

- (IBAction)seeLocations:(id)sender;
- (IBAction)birdImagepinch:(UIPinchGestureRecognizer *)sender;
- (IBAction)birdImagePan:(UIPanGestureRecognizer *)sender;

@end

@implementation BirdController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.birdDescription.scrollsToTop = YES;
    
    NSMutableArray *locations = [NSMutableArray array];
    if (!self.bird.observedPositionsCoordinates){
        for (NSDictionary *location in self.bird.observedPositionsFromDb){
            Coordinates *currentPositions = [Coordinates coordinatesWithDict: location];
            [locations addObject:currentPositions];
        }
    }
    self.bird.observedPositionsCoordinates = locations;
    
    self.birdName.text = self.bird.name;
    self.birdLatinName.text = self.bird.latinName;
    self.birdDescription.text = self.bird.descr;
    
    NSString *imageUrl = self.bird.picture;
    NSData *pictureData = [[NSData alloc]initWithBase64EncodedString:imageUrl options:NSDataBase64DecodingIgnoreUnknownCharacters];
    self.birdImageView.image = [UIImage imageWithData:pictureData];
    self.birdImageView.contentMode = UIViewContentModeScaleAspectFit;
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
    locationsController.locations = self.bird.observedPositionsCoordinates;
    [self.navigationController pushViewController:locationsController animated:YES];
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
