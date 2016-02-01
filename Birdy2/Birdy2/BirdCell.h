//
//  BirdCell.h
//  Birdy2
//
//  Created by veso on 1/31/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BirdCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *birdCellImageView;
@property (weak, nonatomic) IBOutlet UILabel *birdCellNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *birdCellLatinNameLabel;

@end
