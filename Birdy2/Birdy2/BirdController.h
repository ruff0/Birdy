#import <UIKit/UIKit.h>
#import "BIrd.h"

@interface BirdController : UIViewController

@property (strong, atomic) Bird *bird;

@property (strong, nonatomic) IBOutlet UILabel *birdName;
@property (weak, nonatomic) IBOutlet UIImageView *birdImageView;
@property (weak, nonatomic) IBOutlet UILabel *birdLatinName;
@property (weak, nonatomic) IBOutlet UITextView *birdDescription;
@property (weak, nonatomic) NSString *descriptionString;

@end
