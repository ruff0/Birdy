#import "AddBirdViewController.h"
#import "Bird.h"
#import "BirdAndDictionary.h"
#import "AppDelegate.h"
#import "BirdsListViewController.h"
#import "HttpData.h"
#import <CoreLocation/CoreLocation.h>

@interface AddBirdViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>
- (IBAction)addNewBird:(id)sender;
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

@end


@implementation AddBirdViewController
{
    NSString *_url;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _url = @"https://protected-falls-94776.herokuapp.com/api/birds";
    self.http = [HttpData httpData];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
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

- (IBAction)addNewBird:(id)sender {    
    Bird *newBird = [Bird BirdWithName:self.birdNamelabel.text withLatinName:self.birdLatinNameLabel.text withDescription:self.birdDescriptionTextView.text withPic:self.imageString withLatitude:self.latitude andWithLongitude:self.longitude];
    
    [self saveBird:newBird];
    
    /*Bird *bird = [Bird BirdWithId:@"5" withName:@"Kanarche" withLatinName:@"Canari de vanari" withPictureUrl:@"6" withDescription:@"Kanarcheta live on the Canary ilands." andWithObservedAt:[NSArray arrayWithObjects: @"here", @"there", nil]];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.data addBird:bird];*/
}

-(void) saveBird:(Bird*)newBird {
    __weak id weakSelf = self;
    
    NSDictionary *dictionaryBird = [newBird dict];
    
    NSDictionary *header = [[NSDictionary alloc] initWithObjectsAndKeys:@"application/json", @"content-type", nil];
    
    [self.http postAt:_url withBody:dictionaryBird headers:header andCompletionHandler:^(NSDictionary *dict, NSError *err) {
        NSInteger responseStatusNumber = 200;
        if (![dict isKindOfClass:[NSArray class]]) {
            if ([dict objectForKey:@"status"]) {
                responseStatusNumber = [[dict objectForKey:@"status"] integerValue];
            }
        }
        
        if(err || (responseStatusNumber >= 400)){
            dispatch_async(dispatch_get_main_queue(), ^{
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
            
            // [[weakSelf navigationController] popViewControllerAnimated:YES];
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
@end
