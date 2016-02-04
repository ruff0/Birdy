//
//  Coordinates.m
//  Birdy2
//
//  Created by veso on 2/4/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import "Coordinates.h"

@implementation Coordinates

- (id)initWithLatitude:(NSString *)aLat
      andWithLongitude:(NSString *)aLon {
    self = [super init];
    if (self) {
        self.latitude = aLat;
        self.longitude = aLon;
    }
    
    return self;
}

+(instancetype)CoordinatesWithLatitude:(NSString*)aLat
               andWithLongitude:(NSString*)aLon {
    return [[self alloc] initWithLatitude:aLat andWithLongitude:aLon];
}

-initWithDict: (NSDictionary*) dict {
    return [self initWithLatitude:[dict objectForKey:@"longitude"] andWithLongitude:[dict objectForKey:@"latitude"]];
}

+(Coordinates *) coordinatesWithDict: (NSDictionary *) dict {
    return [[Coordinates alloc] initWithDict:dict];
}

-(id) dict {
    return @{
             @"latitude": self.latitude,
             @"longitude": self.longitude
    };
}

@end
