#import "AddBirdViewController.h"
#import "Bird.h"
#import "BirdAndDictionary.h"
#import "AppDelegate.h"
#import "BirdsListViewController.h"
#import "HttpData.h"
#import "Coordinates.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface AddBirdViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

- (IBAction)addPhotoClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *birdImageView;
@property (strong, nonatomic) NSString *imageString;

@property (weak, nonatomic) IBOutlet UITextField *birdNamelabel;
@property (weak, nonatomic) IBOutlet UITextField *birdLatinNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *birdDescriptionTextView;

@property (strong, nonatomic) HttpData *http;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSString* latitude;
@property (strong, nonatomic) NSString* longitude;

@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

- (IBAction)changePicture:(UILongPressGestureRecognizer *)sender;

@end


@implementation AddBirdViewController
{
    NSString *_url;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* addBirdyItem = [[UIBarButtonItem alloc]initWithTitle:@"Done!" style:UIBarButtonItemStyleDone target:self action:@selector(addNewBird)];
    self.navigationItem.rightBarButtonItem = addBirdyItem;
    
    UIImageView *scriptLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scriptLogo"]];
    scriptLogoView.contentMode = UIViewContentModeScaleAspectFit;
    scriptLogoView.frame = CGRectMake(0, 0, 30.0, 30.0);
    self.navigationItem.titleView = scriptLogoView;
    
    _url = @"https://protected-falls-94776.herokuapp.com/api/birds";
    self.http = [HttpData httpData];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    [[self.birdDescriptionTextView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.birdDescriptionTextView layer] setBorderWidth:0.3];
    [[self.birdDescriptionTextView layer] setCornerRadius:5];
    
    self.birdImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.birdImageView.userInteractionEnabled = YES;
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingIndicator setHidesWhenStopped:YES];
    [self.loadingIndicator setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]];
    [self.view addSubview:self.loadingIndicator];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissModalViewControllerAnimated:YES];
    
    NSData *data = UIImagePNGRepresentation(image);
    self.imageString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    self.birdImageView.image = [UIImage imageWithData:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addNewBird {
    
    if(self.birdNamelabel == nil || [self.birdNamelabel.text isEqualToString:@""] || self.birdNamelabel.text.length < 3 || self.birdNamelabel.text.length > 30) {
        [self showErrorAlert:@"Bird name should be filled in and longer than 3 letters."];
        return;
    }
    
    if(self.birdLatinNameLabel == nil || [self.birdLatinNameLabel.text isEqualToString:@""] || self.birdLatinNameLabel.text.length < 3 || self.birdLatinNameLabel.text.length > 30) {
        [self showErrorAlert:@"Bird latin name should be filled in and longer than 3 letters."];
        return;
    }
    
    if(self.birdDescriptionTextView == nil || [self.birdDescriptionTextView.text isEqualToString:@""] || self.birdDescriptionTextView.text.length < 3 || self.birdDescriptionTextView.text.length > 30) {
        [self showErrorAlert:@"Bird description should be filled in and longer than 3 letters."];
        return;
    }
    
    if(self.imageString == nil || [self.imageString isEqualToString:@""] || self.imageString.length < 3) {
        [self showErrorAlert:@"Bird picture should be selected."];
        return;
    }
    
    if(self.imageString.length > 2000000) {
        [self showErrorAlert:@"Bird picture should be with size less than 150kB."];
        return;
    }
    
    if (self.latitude == nil || [self.latitude isEqualToString:@""] || self.longitude == nil || [self.longitude isEqualToString:@""]) {
        [self showErrorAlert:@"Your current coordinates cannot be obtained."];
        return;
    }
    
    Bird *newBird = [Bird BirdWithName:self.birdNamelabel.text withLatinName:self.birdLatinNameLabel.text withDescription:self.birdDescriptionTextView.text withPic:self.imageString withLatitude:self.latitude andWithLongitude:self.longitude];
    
    [self saveBird:newBird];
}

-(void) showErrorAlert:(NSString*) message {
    UIAlertController *validationAlertController = [UIAlertController alertControllerWithTitle:@"Input validation failed" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [validationAlertController addAction:actionOk];
    [self presentViewController:validationAlertController animated:YES completion:nil];
}


-(void) saveBird:(Bird*)newBird {
    __weak id weakSelf = self;
    
    NSDictionary *dictionaryBird = [newBird dict];
    
    NSDictionary *header = [[NSDictionary alloc] initWithObjectsAndKeys:@"application/json", @"content-type", nil];

    [self.loadingIndicator startAnimating];
    
    [self.http postAt:_url withBody:dictionaryBird headers:header andCompletionHandler:^(NSDictionary *dict, NSError *err) {
        NSInteger responseStatusNumber = 200;
        if (![dict isKindOfClass:[NSArray class]]) {
            if ([dict objectForKey:@"status"]) {
                responseStatusNumber = [[dict objectForKey:@"status"] integerValue];
            }
        }
        
        if(err || (responseStatusNumber >= 400)){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[weakSelf loadingIndicator] stopAnimating];
                UIAlertController *failAlertController = [UIAlertController alertControllerWithTitle:@"Adding birdy failed" message:@"Network access or connectivity problems terminated the action." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [failAlertController addAction:actionOk];
                [weakSelf presentViewController:failAlertController animated:YES completion:nil];
            });
            
            return;
        }
        
        Bird *resultsBird = [Bird birdWithDict:dict];
        
        [weakSelf saveNewTemporaryBirdyToCd:resultsBird];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[weakSelf loadingIndicator] stopAnimating];
            UIAlertController *successAlertController = [UIAlertController alertControllerWithTitle:@"Adding birdy successful" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // Why this does not work?
                [[weakSelf navigationController] popViewControllerAnimated:YES];
            }];
            [successAlertController addAction:actionOk];
            [weakSelf presentViewController:successAlertController animated:YES completion:nil];
        });
    }];
}

-(void) saveNewTemporaryBirdyToCd:(Bird*) newBird {
    NSManagedObjectContext  *managedContext = ((AppDelegate*) [UIApplication sharedApplication].delegate).managedObjectContext;
    
    NSEntityDescription *birdDescription = [NSEntityDescription entityForName:@"Bird" inManagedObjectContext:managedContext];
    NSEntityDescription *coordinatesDescription = [NSEntityDescription entityForName:@"Coordinates" inManagedObjectContext:managedContext];
    
    NSManagedObject *theCurrentBird = [[NSManagedObject alloc] initWithEntity:birdDescription insertIntoManagedObjectContext:managedContext];
    [theCurrentBird setValue:newBird.id forKey:@"id"];
    [theCurrentBird setValue:newBird.name forKey:@"name"];
    [theCurrentBird setValue:newBird.latinName forKey:@"latinName"];
    [theCurrentBird setValue:newBird.descr forKey:@"descr"];
    [theCurrentBird setValue:newBird.picture forKey:@"picture"];
    [theCurrentBird setValue:[NSNumber numberWithBool:YES] forKey:@"temporary"];
        
    for (NSDictionary *location in newBird.observedPositionsFromDb){
        Coordinates *currentPositions = [Coordinates coordinatesWithDict: location];
        NSManagedObject *theCurrentCoordinates = [[NSManagedObject alloc] initWithEntity:coordinatesDescription insertIntoManagedObjectContext:managedContext];
        [theCurrentCoordinates setValue:currentPositions.latitude forKey:@"latitude"];
        [theCurrentCoordinates setValue:currentPositions.longitude forKey:@"longitude"];
        [theCurrentCoordinates setValue:newBird.id forKey:@"birdyId"];
        [theCurrentCoordinates setValue:theCurrentBird forKey:@"bird"];
    }
    
    NSError *coreDataErr;
    if (![managedContext save:&coreDataErr]) {
        NSLog(@"Error saving new birdy to core data: %@\n%@", [coreDataErr localizedDescription], [coreDataErr userInfo]);
        return;
    }
}

- (IBAction)addPhotoClick:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }];
        
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    if (currentLocation != nil) {
        self.longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
}
- (IBAction)changePicture:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGFloat currentScale = self.birdImageView.frame.size.width / self.birdImageView.bounds.size.width;
        CGFloat newScale = currentScale * 0.8;
        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
        self.birdImageView.transform = transform;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat currentScale = self.birdImageView.frame.size.width / self.birdImageView.bounds.size.width;
        CGFloat newScale = currentScale / 0.8;
        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
        self.birdImageView.transform = transform;
    }
    
    [self addPhotoClick:sender];
}
@end
