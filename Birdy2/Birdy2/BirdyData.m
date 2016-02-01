//
//  BirdyData.m
//  Birdy2
//
//  Created by veso on 1/31/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import "BirdyData.h"
#import "Bird.h"

@interface BirdyData()

@property NSMutableArray *birds;

@end

@implementation BirdyData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.birds = [self fillWithBirds];
    }
    return self;
}

- (NSMutableArray*) fillWithBirds {
    
    Bird *kos = [Bird BirdWithId:@"1" withName:@"Kos" withLatinName:@"Kosus magnus" withPictureUrl:@"1" withDescription:@"Kos is little simpatic bird." andWithObservedAt:[NSArray arrayWithObjects: @"here", @"there", nil]];
    
    Bird *garvan = [Bird BirdWithId:@"2" withName:@"Garvan" withLatinName:@"Garvanus evnatus" withPictureUrl:@"2" withDescription:@"Garvan is very clever bird." andWithObservedAt:[NSArray arrayWithObjects: @"here", @"there", nil]];
    
    Bird *siniger = [Bird BirdWithId:@"3" withName:@"Siniger" withLatinName:@"Sinigerus royalis" withPictureUrl:@"3" withDescription:@"This is the best one of all." andWithObservedAt:[NSArray arrayWithObjects: @"here", @"there", nil]];
    
    Bird *chinka = [Bird BirdWithId:@"4" withName:@"Chinka" withLatinName:@"Chinkus" withPictureUrl:@"4" withDescription:@"You can see it all arownd you in the city." andWithObservedAt:[NSArray arrayWithObjects: @"here", @"there", nil]];
    
    return [NSMutableArray arrayWithObjects: kos, garvan, siniger, chinka, nil];
}

- (NSArray*) allBirds {
    return self.birds;
};

- (void) addBird:(Bird*) newBird {
    [self.birds addObject:newBird];
};


@end
