#import <Foundation/Foundation.h>

#import "BIrd.h"

@interface Bird (Dictionaries)

-initWithDict: (NSDictionary*) dict;

-initWithDict: (NSDictionary*) dict
andWithPicture: (NSString*) pic;

+(Bird *) birdWithDict: (NSDictionary *) dict;

+(Bird *) birdWithDict: (NSDictionary *) dict
        andWithPicture: (NSString *) pic;

-dict;

@end
