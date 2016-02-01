//
//  BirdsContentController.m
//  Birdy2
//
//  Created by veso on 2/1/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import "BirdsContentController.h"
#import "BirdController.h"

@interface BirdsContentController ()

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (strong, nonatomic) IBOutlet UIPageControl *pageCOntrol;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation BirdsContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUInteger numberPages = self.birdsArray.count;
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(320 * numberPages, CGRectGetHeight(self.scrollView.frame));
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageCOntrol.numberOfPages = numberPages;
    self.pageCOntrol.currentPage = 0;
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.birdsArray.count) {
        return;
    }
    
    // replace the placeholder if necessary
    BirdController *controller = [self.viewControllers objectAtIndex:page];
    
    Bird *currentBird = [self.birdsArray objectAtIndex: page];
    
    if ((NSNull *)controller == [NSNull null]) {
        
        NSString *birdStoryBoard = @"bird";        
        controller = [self.storyboard instantiateViewControllerWithIdentifier:birdStoryBoard];
        controller.bird = currentBird;
        
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        
        controller.birdName.text = currentBird.name;
        
        controller.birdLatinName.text = currentBird.latinName;
        controller.birdDescription.text = currentBird.description;
        NSString *imageUrl = currentBird.pictureUrl;
        controller.birdImageView.contentMode = UIViewContentModeScaleAspectFit;
        controller.birdImageView.image = [UIImage imageNamed:imageUrl];
        
    }
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page >= self.birdsArray.count) {
        return;
    }
    
    self.pageCOntrol.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // remove all the subviews from our scrollview
    for (UIView *view in self.scrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSUInteger numPages = self.birdsArray.count;
    
    // adjust the contentSize (larger or smaller) depending on the orientation
    self.scrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numPages, CGRectGetHeight(self.scrollView.frame));
    
    // clear out and reload our pages
    self.viewControllers = nil;
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numPages; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    [self loadScrollViewWithPage:self.pageCOntrol.currentPage - 1];
    [self loadScrollViewWithPage:self.pageCOntrol.currentPage];
    [self loadScrollViewWithPage:self.pageCOntrol.currentPage + 1];
    [self gotoPage:NO]; // remain at the same page (don't animate)
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageCOntrol.currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)pageChanged:(id)sender {
    [self gotoPage:YES];
}


@end
