#import "AddBirdViewController.h"
#import "Bird.h"
#import "BirdAndDictionary.h"
#import "AppDelegate.h"
#import "BirdsListViewController.h"
#import "HttpData.h"
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
    
    _url = @"https://protected-falls-94776.herokuapp.com/api/birds";
    self.http = [HttpData httpData];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
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
    [self.loadingIndicator setBackgroundColor:[UIColor colorWithRed:50.0 green:50.0 blue:50.0 alpha:0.5]];
    [self.view addSubview:self.loadingIndicator];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
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
    Bird *newBird = [Bird BirdWithName:self.birdNamelabel.text withLatinName:self.birdLatinNameLabel.text withDescription:self.birdDescriptionTextView.text withPic:self.imageString withLatitude:self.latitude andWithLongitude:self.longitude];
    
    [self saveBird:newBird];
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *pictureData = [[NSData alloc]initWithBase64EncodedString:resultsBird.picture options:NSDataBase64DecodingIgnoreUnknownCharacters];
            self.birdImageView.image = [UIImage imageWithData:pictureData];
            
            [[weakSelf loadingIndicator] stopAnimating];
            UIAlertController *successAlertController = [UIAlertController alertControllerWithTitle:@"Adding birdy successful" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [successAlertController addAction:actionOk];
            [weakSelf presentViewController:successAlertController animated:YES completion:nil];
            
            [[weakSelf navigationController] popViewControllerAnimated:YES];
        });
    }];
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
    [self addPhotoClick:sender];
}
@end
