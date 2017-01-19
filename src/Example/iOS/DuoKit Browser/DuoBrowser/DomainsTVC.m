//
//  DomainsTVC.m
//  DuoBrowser
//
//  The MIT License (MIT)
//
//  Copyright © 2017 Zhi-Wei Cai (MediaTek Inc.). All rights reserved.
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

#import "DomainsTVC.h"
#import "DomainCell.h"
#import "ServicesTVC.h"
#import <DuoKit/DuoKit.h>

@interface DomainsTVC () <DuoBrowserDelegate>
{
    UIActivityIndicatorView *indicator;
}

@property (nonatomic, strong) NSMutableArray<NSString *>    *dataSource;
@property (nonatomic, strong) DuoBrowser                    *browser;

@end

@implementation DomainsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchForDomains)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchForDomains)
                                                 name:kNSNetworkReachabilityDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self searchForDomains];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self hideActivityView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)searchForDomains
{
    _dataSource = [NSMutableArray new];
    [self.tableView reloadData];
    
    [self showActivityView];
    
    _browser = nil;
    _browser = [DuoBrowser new];
    _browser.delegate = self;
    [_browser searchForBrowsableDomains];
}

#pragma mark - DuoBrowserDelegate

- (void)domainsDidChanged:(NSArray<NSString *> *)domains
{
    self.tableView.userInteractionEnabled = NO;
    
    _dataSource = [NSMutableArray arrayWithArray:domains];
    
    if (_dataSource.count) {
        [self hideActivityView];
    } else {
        [self showActivityView];
    }
    
    [self.tableView reloadData];
    
    self.tableView.userInteractionEnabled = YES;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

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
    DomainCell *cell = [tableView dequeueReusableCellWithIdentifier:kDomainCellIdentifer
                                                       forIndexPath:indexPath];
    
    NSString *domain = [_dataSource objectAtIndex:indexPath.row];
    
    cell.title.text = [domain hasSuffix:@"."] ?
    [domain substringToIndex:domain.length-1] :
    domain;
    indicator = cell.indicator;
    [cell.indicator stopAnimating];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DomainCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.indicator.color = kColorBase;
    [cell.indicator startAnimating];
    
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
        if (indicator) {
            [indicator stopAnimating];
        }
    }
}

@end
