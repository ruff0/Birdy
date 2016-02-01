//
//  DetailViewController.h
//  BirdyApplication
//
//  Created by veso on 1/31/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

