//
//  BirdyData.h
//  Birdy2
//
//  Created by veso on 1/31/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bird.h"

@interface BirdyData : NSObject

- (NSArray*) allBirds;

- (void) addBird:(Bird*) newBird;

@end
