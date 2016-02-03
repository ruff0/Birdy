#import "BirdAndDictionary.h"

@implementation Bird (Dictionaries)

-(id)initWithDict:(NSDictionary *)dict  {
    
    return [self initWithId:[dict objectForKey:@"_id"]
                   withName:[dict objectForKey:@"name"]
              withLatinName:[dict objectForKey:@"latinName"]
             withPictureUrl:[dict objectForKey:@"picture"]
            withDescription:[dict objectForKey:@"description"]
          andWithObservedAt:[dict objectForKey:@"coordinates"]];
}

-(id)initWithDict: (NSDictionary*) dict andWithPicture: (NSString*) pic {
    return [self initWithId:[dict objectForKey:@"_id"]
                   withName:[dict objectForKey:@"name"]
              withLatinName:[dict objectForKey:@"latinName"]
             withPictureUrl:pic
            withDescription:[dict objectForKey:@"description"]
          andWithObservedAt:[dict objectForKey:@"coordinates"]];
}

-(id)dict {
    return @{
             @"name": self.name,
             @"latinName": self.latinName,
             @"picture": self.pictureUrl,
             @"description": self.description,
             @"coordinates": self.observed
             };
}

+(Bird *)birdWithDict:(NSDictionary *)dict {
    return [[Bird alloc] initWithDict:dict];
}

+(Bird *)birdWithDict:(NSDictionary *)dict
       andWithPicture: (NSString *) pic {
    return [[Bird alloc] initWithDict:dict andWithPicture:pic];
}


@end
