#import "BirdAndDictionary.h"

@implementation Bird (Dictionaries)

-(id)initWithDict:(NSDictionary *)dict  {
    
    return [self initWithId:[dict objectForKey:@"_id"]
                   withName:[dict objectForKey:@"name"]
              withLatinName:[dict objectForKey:@"latinName"]
                    withPic:[dict objectForKey:@"picture"]
            withDescription:[dict objectForKey:@"descr"]
           andWithPositions:[dict objectForKey:@"coordinates"]];
}

-(id) dict {
    return @{
             @"name": self.name,
             @"latinName": self.latinName,
             @"picture": self.picture,
             @"descr": self.descr,
             @"latitude": self.latitude,
             @"longitude":self.longitude
    };
}

+(Bird *)birdWithDict:(NSDictionary *)dict {
    return [[Bird alloc] initWithDict:dict];
}

@end
