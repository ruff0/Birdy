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

- (id)initWithLatitude:(NSString *)aLat
      withLongitude:(NSString *)aLon
        andWithBirdyId:(NSString*)aId {
    self = [super init];
    if (self) {
        self.latitude = aLat;
        self.longitude = aLon;
        self.birdyId = aId;
    }
    
    return self;
}

+(instancetype)CoordinatesWithLatitude:(NSString*)aLat
               andWithLongitude:(NSString*)aLon {
    return [[self alloc] initWithLatitude:aLat andWithLongitude:aLon];
}

+(instancetype)CoordinatesWithLatitude:(NSString*)aLat
                      andWithLongitude:(NSString*)aLon
                        andWithBirdyId:(NSString*)aId{
    return [[self alloc] initWithLatitude:aLat withLongitude:aLon andWithBirdyId:aId];
}

-initWithDict: (NSDictionary*) dict {
    return [self initWithLatitude:[dict objectForKey:@"longitude"]
                 andWithLongitude:[dict objectForKey:@"latitude"]];
}

-initWithDictAndBirdId: (NSDictionary*) dict {
    return [self initWithLatitude:[dict objectForKey:@"longitude"]
                    withLongitude:[dict objectForKey:@"latitude"]
                   andWithBirdyId:[dict objectForKey:@"birdyId"]];
}

+(Coordinates *) coordinatesWithDict: (NSDictionary *) dict {
    return [[Coordinates alloc] initWithDict:dict];
}

+(Coordinates *) coordinatesWithDictAndBirdId: (NSDictionary *) dict {
    return [[Coordinates alloc] initWithDictAndBirdId:dict];
}

-(id) dict {
    return @{
             @"latitude": self.latitude,
             @"longitude": self.longitude
    };
}

@end
