//
//  DetailTVC.m
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

#import "DetailTVC.h"
#import "DetailSwitchCell.h"
#import "DetailSetterCell.h"
#import "DetailSliderCell.h"

#define kDetailWebUICellIdentifer   @"DetailWebUICell"

@interface DetailTVC () <UITextFieldDelegate>

@end

@implementation DetailTVC

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (id cell in self.tableView.visibleCells) {
        if ([cell respondsToSelector:@selector(setReloadInterval:)]) {
            [cell setReloadInterval:0];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _duo.layout.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTKDuoUI *ui = [_duo.layout objectAtIndex:indexPath.row];
    switch (ui.type) {
        case DuoUIWebUI: {
            UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:kDetailWebUICellIdentifer
                                            forIndexPath:indexPath];
            cell.textLabel.text = ui.name ? ui.name : _duo.name;
            cell.detailTextLabel.text = _duo.v4Addresses.count ?
            [_duo.v4Addresses firstObject] : _duo.v6Addresses.count ?
            [_duo.v6Addresses firstObject] : nil;
            return cell;
        }
        case DuoUISwitch: {
            DetailSwitchCell *cell =
            [tableView dequeueReusableCellWithIdentifier:kDetailSwitchCellIdentifer
                                            forIndexPath:indexPath];
            cell.textLabel.text = ui.name;
            cell.duo = _duo;
            cell.pin = ui.pin;
            [cell setReloadInterval:ui.reloadInterval];
            return cell;
        }
        case DuoUISetter:
        case DuoUIGetter: {
            DetailSetterCell *cell =
            [tableView dequeueReusableCellWithIdentifier:kDetailSetterCellIdentifer
                                            forIndexPath:indexPath];
            cell.title.text = ui.name;
            cell.duo = _duo;
            cell.key = ui.key;
            cell.textField.userInteractionEnabled = ui.type == DuoUISetter;
            [cell setReloadInterval:ui.reloadInterval];
            return cell;
        }
        case DuoUISlider: {
            DetailSliderCell *cell =
            [tableView dequeueReusableCellWithIdentifier:kDetailSliderCellIdentifer
                                            forIndexPath:indexPath];
            cell.title.text = ui.name;
            cell.duo = _duo;
            cell.key = ui.key;
            cell.slider.minimumValue = ui.minimumValue;
            cell.slider.maximumValue = ui.maximumValue;
            [cell setReloadInterval:ui.reloadInterval];
            return cell;
        }
        default:
            break;
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([_duo.layout objectAtIndex:indexPath.row].type) {
        case DuoUIWebUI:
            [self openWebUI:_duo];
            break;
        default:
            break;
    }
}

#pragma mark - Methods

- (void)openWebUI:(MTKDuo *)duo
{
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:
              [NSString stringWithFormat:@"http://%@%@:%@",
               duo.user ? [NSString stringWithFormat:@"%@%@@",
                           duo.user,
                           duo.password ?
                           [NSString stringWithFormat:@":%@", duo.password] : @""] : @"",
               duo.host,
               duo.port ? [NSString stringWithFormat:@"%ld",
                           (long)duo.port] : @""]]];
}

@end
