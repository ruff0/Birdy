//
//  AddBirdViewController.m
//  Birdy2
//
//  Created by veso on 1/31/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import "AddBirdViewController.h"
#import "Bird.h"
#import "AppDelegate.h"
#import "BirdsListViewController.h"

@interface AddBirdViewController ()
- (IBAction)addNewBird:(id)sender;

@end

@implementation AddBirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addNewBird:(id)sender {
    Bird *bird = [Bird BirdWithId:@"5" withName:@"Kanarche" withLatinName:@"Canari de vanari" withPictureUrl:@"6" withDescription:@"Kanarcheta live on the Canary ilands." andWithObservedAt:[NSArray arrayWithObjects: @"here", @"there", nil]];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.data addBird:bird];
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
