//
//  BrowserTVC.m
//  DuoKit Browser
//
//  Created by Cai on 17/01/2017.
//  Copyright © 2017 MediaTek Inc. All rights reserved.
//

#import "BrowserTVC.h"

@interface BrowserTVC ()
{
    UIActivityIndicatorView *activityView;
}

@end

@implementation BrowserTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tabBarController.tabBar setTintColor:kColorBase];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    navigationBar.tintColor       = kColorTint;
    navigationBar.barTintColor    = kColorBase;
    navigationBar.translucent     = NO;
    
    navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:navigationBar.bounds
                                                                cornerRadius:navigationBar.layer.cornerRadius].CGPath;
    [navigationBar.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [navigationBar.layer setShadowOffset:CGSizeMake(.0f, 1.f)];
    [navigationBar.layer setShadowRadius:1.f];
    [navigationBar.layer setShadowOpacity:.3f];
}

- (void)showActivityView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!activityView) {
            activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
            [self.tableView addSubview:activityView];
            activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            activityView.color = kColorBase;
            activityView.hidesWhenStopped = YES;
            [activityView layer].zPosition = 1;
        }
        CGPoint center = CGPointMake(self.view.center.x, self.view.center.y - self.navigationController.navigationBar.bounds.size.height);
        [activityView setCenter:center];
        [activityView startAnimating];
    });
}

- (void)hideActivityView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [activityView stopAnimating];
    });
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger sectionDelay = 0;
    for (NSUInteger i = 0; i < indexPath.section; i++) {
        sectionDelay += [tableView numberOfRowsInSection:i];
    }
    cell.alpha = .0f;
    cell.transform = CGAffineTransformMakeScale(.8f, .5f);
    [UIView animateWithDuration:.2f
                          delay:(sectionDelay + indexPath.row) * .05f
                        options:UIViewAnimationOptionTransitionFlipFromTop|UIViewAnimationOptionTransitionCrossDissolve
                     animations:^ {
                         cell.transform = CGAffineTransformIdentity;
                         cell.alpha = 1.0f;
                     } completion:nil];
}

@end
