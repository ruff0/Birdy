#import <Foundation/Foundation.h>

#import "BIrd.h"

@interface Bird (Dictionaries)

-initWithDict: (NSDictionary*) dict;

+(Bird *) birdWithDict: (NSDictionary *) dict;

- dict;

@end
