#import "BirdController.h"
#import "Birdy2-Swift.h"
#import "Coordinates.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface BirdController ()

- (IBAction)seeLocations:(id)sender;
- (IBAction)birdImagepinch:(UIPinchGestureRecognizer *)sender;
- (IBAction)birdImagePan:(UIPanGestureRecognizer *)sender;

@end

@implementation BirdController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.birdName.text = self.bird.name;
    self.birdLatinName.text = self.bird.latinName;
    self.birdDescription.text = self.bird.descr;
    self.birdDescription.scrollsToTop = YES;
    
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

-(NSManagedObjectContext*) managedContext {
    return((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
}

-(NSMutableArray*) getCoordinatesFromCd:(NSString*) birdId {
    // Here I am getting the coordinates of the current bird from CD
    
    NSError *fetchErrorCoordinates = nil;
    NSFetchRequest *coordinatesRequest = [[NSFetchRequest alloc]initWithEntityName:@"Coordinates"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"birdyId == %@", birdId];
    [coordinatesRequest setPredicate:predicate];
    
    NSArray *coordinatesFromCoreData = [self.managedContext executeFetchRequest:coordinatesRequest error:&fetchErrorCoordinates];
    if (fetchErrorCoordinates) {
        NSLog(@"Error fetching birdies from core data: %@\n%@", [fetchErrorCoordinates localizedDescription], [fetchErrorCoordinates userInfo]);
        return nil;
    }
    
    NSMutableArray *coordinates = [[NSMutableArray alloc]init];
    for (NSManagedObject *cdCoordinates in coordinatesFromCoreData) {
        NSString *latitude = [cdCoordinates valueForKey:@"latitude"];
        NSString *longitude = [cdCoordinates valueForKey:@"longitude"];
        
        Coordinates *currentCoordinates = [Coordinates CoordinatesWithLatitude:latitude andWithLongitude:longitude];
        
        [coordinates addObject:currentCoordinates];
    };
    
    return coordinates;
}

- (IBAction)seeLocations:(id)sender {
    LocationsViewController *locationsController = [[LocationsViewController alloc]init];
    locationsController.locations = [self getCoordinatesFromCd:self.bird.id];
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
