#import "AddBirdViewController.h"
#import "Bird.h"
#import "AppDelegate.h"
#import "BirdsListViewController.h"

@interface AddBirdViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (IBAction)addNewBird:(id)sender;
- (IBAction)addPhotoClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *birdImageView;

@end

@implementation AddBirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    
    NSData *data = UIImagePNGRepresentation(image);
    NSString *imageString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSData *reversedData = [[NSData alloc]initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    self.birdImageView.image = [UIImage imageWithData:reversedData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addNewBird:(id)sender {
    Bird *bird = [Bird BirdWithId:@"5" withName:@"Kanarche" withLatinName:@"Canari de vanari" withPictureUrl:@"6" withDescription:@"Kanarcheta live on the Canary ilands." andWithObservedAt:[NSArray arrayWithObjects: @"here", @"there", nil]];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.data addBird:bird];
    
    [self.navigationController popViewControllerAnimated:YES];
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
@end

/* - (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
} 
 
 - (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
 NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
 return [UIImage imageWithData:data];
 }
 
 - (NSString *)imageToNSString:(UIImage *)image
 {
 NSData *data = UIImagePNGRepresentation(image);
 
 return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
 }
 
 - (UIImage *)stringToUIImage:(NSString *)string
 {
 NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
 
 return [UIImage imageWithData:data];
 }
 
 
 */
