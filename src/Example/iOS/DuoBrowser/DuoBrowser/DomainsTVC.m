//
//  DomainsTVC.m
//  DuoBrowser
//
//  The MIT License (MIT)
//
//  Copyright © 2017 Zhi-Wei Cai. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "DomainsTVC.h"
#import "ServicesTVC.h"

#import <DuoKit/DuoKit.h>

#define kDomainCellIdentifer    @"DomainCell"
#define kServiceSegueIdentifer  @"ServiceSegue"

@interface DomainsTVC () <MTKDuoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *>    *dataSource;
@property (nonatomic, strong) MTKDuoBrowser                 *browser;

@end

@implementation DomainsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    navigationBar.tintColor       = [UIColor whiteColor];
    navigationBar.barTintColor    = UIColorFromRGB(0xFF3B30);
    navigationBar.translucent     = NO;
    
    navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:navigationBar.bounds
                                                                cornerRadius:navigationBar.layer.cornerRadius].CGPath;
    [navigationBar.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [navigationBar.layer setShadowOffset:CGSizeMake(.0f, 1.f)];
    [navigationBar.layer setShadowRadius:1.f];
    [navigationBar.layer setShadowOpacity:.3f];
    
    _dataSource = [NSMutableArray new];
    
    _browser = [MTKDuoBrowser sharedInstance];
    _browser.delegate = self;
    [_browser searchForBrowsableDomains];
}

#pragma mark - MTKDuoBrowserDelegate

- (void)domainsDidChanged:(NSArray<NSString *> *)domains
{
    _dataSource = [NSMutableArray arrayWithArray:domains];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Available Domains";
        default:
            return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDomainCellIdentifer
                                                            forIndexPath:indexPath];
    
    NSString *domain = [_dataSource objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [domain hasSuffix:@"."] ?
    [domain substringToIndex:domain.length-1] :
    domain;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:kServiceSegueIdentifer sender:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:kServiceSegueIdentifer]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        ServicesTVC *vc = (ServicesTVC *)segue.destinationViewController;
        vc.domain = [_dataSource objectAtIndex:indexPath.row];
        vc.serviceType = kBonjourServiceTypeHTTP;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.alpha = .0f;
    cell.transform = CGAffineTransformMakeScale(.8f, .5f);
    [UIView animateWithDuration:.2f
                          delay:indexPath.row * .1f
                        options:UIViewAnimationOptionTransitionFlipFromTop|UIViewAnimationOptionTransitionCrossDissolve
                     animations:^ {
                         cell.transform = CGAffineTransformIdentity;
                         cell.alpha = 1.0f;
                     } completion:nil];
}

@end
