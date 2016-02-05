//
//  AppDelegate.h
//  Birdy2
//
//  Created by veso on 1/31/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BirdyData.h"
@import GoogleMaps;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BirdyData *data;

@end

