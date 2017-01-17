//
//  ServicesTVC.m
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

#import "ServicesTVC.h"
#import "ServiceCell.h"
#import "DetailTVC.h"
#import <DuoKit/DuoKit.h>

@interface ServicesTVC () <DuoBrowserDelegate>
{
    UIActivityIndicatorView *indicator;
}

@property (nonatomic, strong) NSMutableArray<Duo *>  *dataSource;
@property (nonatomic, strong) DuoBrowser             *browser;

@end

@implementation ServicesTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Select a Service";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchForServices)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchForServices)
                                                 name:kNSNetworkReachabilityDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self searchForServices];
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

- (void)searchForServices
{
    _dataSource = [NSMutableArray new];
    [self.tableView reloadData];
    
    [self showActivityView];
    
    _browser = nil;
    _browser = [DuoBrowser new];
    _browser.delegate = self;
    [_browser searchForServicesOfType:_serviceType
                             inDomain:_domain];
}

#pragma mark - DuoBrowserDelegate

- (void)duoListDidChanged:(NSArray<Duo *> *)duoList
{
    self.tableView.userInteractionEnabled = NO;
    
    _dataSource = [NSMutableArray arrayWithArray:duoList];
    
    if (_dataSource.count) {
        [self hideActivityView];
    } else {
        [self showActivityView];
    }
    
    [self.tableView reloadData];
    
    self.tableView.userInteractionEnabled = YES;
}

- (void)didResolveDuo:(Duo *)duo
{
    [duo isDeviceReadyWithApi:kDuoKitMinVersion
            completionHandler:^(NSInteger api,
                                BOOL isReady,
                                NSString *profile,
                                NSArray *layouts,
                                NSString *errorMessage) {
                if (isReady) {
                    NSLog(@"%s: %@", __PRETTY_FUNCTION__, layouts);
                    NSMutableArray *layoutArray = [NSMutableArray new];
                    for (NSDictionary *dict in layouts) {
                        DuoUI *ui = [[DuoUI alloc] initWithDictionary:dict];
                        if (ui) {
                            [layoutArray addObject:ui];
                        }
                    }
                    if (profile) {
                        duo.profile = profile;
                    }
                    if (layoutArray.count) {
                        duo.layout = layoutArray;
                    }
                    [self performSegueWithIdentifier:kDetailSegueIdentifer sender:duo];
                } else {
                    
                    if (indicator) {
                        [indicator stopAnimating];
                    }
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                   message:errorMessage
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {
                                                                              self.tableView.userInteractionEnabled = YES;
                                                                          }];
                    [alert addAction:defaultAction];
                    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert
                                                                                                     animated:YES
                                                                                                   completion:nil];
                }
            }];
}

- (void)didNotResolveDuo:(Duo *)duo error:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    if (indicator) {
        [indicator stopAnimating];
    }
    self.tableView.userInteractionEnabled = YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kDetailSegueIdentifer]) {
        Duo *duo = (Duo *)sender;
        DetailTVC *vc = (DetailTVC *)segue.destinationViewController;
        vc.duo = duo;
        vc.navigationItem.title = duo.profile ? duo.profile : duo.name;
        
        if (indicator) {
            [indicator stopAnimating];
        }
        self.tableView.userInteractionEnabled = YES;
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [NSString stringWithFormat:@"Available Services in \"%@\"",
                    [_domain hasSuffix:@"."] ?
                    [_domain substringToIndex:_domain.length-1] :
                    _domain];
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
    ServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceCellIdentifer
                                                        forIndexPath:indexPath];
    
    Duo *duo = (Duo *)[_dataSource objectAtIndex:indexPath.row];
    cell.title.text = duo.name;
    cell.indicator.color = kColorBase;
    indicator = cell.indicator;
    [cell.indicator stopAnimating];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.tableView.userInteractionEnabled = NO;
    
    ServiceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.indicator startAnimating];
    
    Duo *duo = (Duo *)[_dataSource objectAtIndex:indexPath.row];
    [_browser resolveService:duo.service
                 withTimeout:5.f];
}

@end
