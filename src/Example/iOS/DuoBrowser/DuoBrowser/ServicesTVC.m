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
#import "DetailTVC.h"
#import <DuoKit/DuoKit.h>

#define kServiceCellIdentifer    @"ServiceCell"

@interface ServicesTVC () <MTKDuoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray<MTKDuo *>  *dataSource;
@property (nonatomic, strong) MTKDuoBrowser             *browser;

@end

@implementation ServicesTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *domain = _domain;
    
    self.navigationItem.title = [domain hasSuffix:@"."] ?
    [domain substringToIndex:domain.length-1] :
    domain;
    
    _dataSource = [NSMutableArray new];
    
    _browser = [MTKDuoBrowser sharedInstance];
    _browser.delegate = self;
    [_browser searchForServicesOfType:_serviceType
                             inDomain:_domain];
}

#pragma mark - MTKDuoBrowserDelegate

- (void)duoListDidChanged:(NSArray<MTKDuo *> *)duoList
{
    _dataSource = [NSMutableArray arrayWithArray:duoList];
    [self.tableView reloadData];
}

- (void)didResolveDuo:(MTKDuo *)duo
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
                        MTKDuoUI *ui = [[MTKDuoUI alloc] initWithDictionary:dict];
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
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                   message:errorMessage
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    [alert addAction:defaultAction];
                    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert
                                                                                                     animated:YES
                                                                                                   completion:nil];
                }
            }];
}

- (void)didNotResolveDuo:(MTKDuo *)duo error:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kDetailSegueIdentifer]) {
        MTKDuo *duo = (MTKDuo *)sender;
        DetailTVC *vc = (DetailTVC *)segue.destinationViewController;
        vc.duo = duo;
        vc.navigationItem.title = duo.profile ? duo.profile : duo.name;
    }
}

#pragma mark - Table view data source

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceCellIdentifer
                                                            forIndexPath:indexPath];
    
    MTKDuo *duo = (MTKDuo *)[_dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = duo.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MTKDuo *duo = (MTKDuo *)[_dataSource objectAtIndex:indexPath.row];
    [_browser resolveService:duo.service
                 withTimeout:30.f];
}

@end
