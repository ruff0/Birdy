//
//  Coordinates.h
//  Birdy2
//
//  Created by veso on 2/4/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Coordinates : NSObject

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *birdyId;

- (id)initWithLatitude:(NSString *)aLat
      andWithLongitude:(NSString *)aLon;

+(instancetype)CoordinatesWithLatitude:(NSString*)aLat
               andWithLongitude:(NSString*)aLon;

-initWithDict: (NSDictionary*) dict;

+(Coordinates *) coordinatesWithDict: (NSDictionary *) dict;

+(Coordinates *) coordinatesWithDictAndBirdId: (NSDictionary *) dict;

- dict;

@end
