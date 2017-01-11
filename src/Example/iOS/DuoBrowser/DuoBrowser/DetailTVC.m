//
//  DetailTVC.m
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

#import "DetailTVC.h"
#import "DetailWebUICell.h"
#import "DetailSwitchCell.h"
#import "DetailSetterCell.h"
#import "DetailSliderCell.h"

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
            DetailWebUICell *cell =
            [tableView dequeueReusableCellWithIdentifier:kDetailWebUICellIdentifer
                                            forIndexPath:indexPath];
            cell.duo = _duo;
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
            if (ui.color) cell.pinSwitch.onTintColor = ui.color;
            [cell.pinSwitch setOn:ui.value animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(indexPath.row * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [cell setReloadInterval:ui.reloadInterval];
            });
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
            cell.value = ui.value;
            cell.textField.text = [NSString stringWithFormat:@"%.*f", 2, ui.value];
            cell.textField.userInteractionEnabled = ui.type == DuoUISetter;
            cell.textField.borderStyle = ui.type == DuoUISetter ? UITextBorderStyleRoundedRect :  UITextBorderStyleNone;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(indexPath.row * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [cell setReloadInterval:ui.reloadInterval];
            });
            return cell;
        }
        case DuoUISlider: {
            DetailSliderCell *cell =
            [tableView dequeueReusableCellWithIdentifier:kDetailSliderCellIdentifer
                                            forIndexPath:indexPath];
            cell.title.text = ui.name;
            cell.duo = _duo;
            cell.key = ui.key;
            if (ui.color) cell.slider.tintColor = ui.color;
            cell.slider.maximumValue = ui.maximumValue;
            cell.slider.minimumValue = ui.minimumValue;
            cell.slider.value = ui.value;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(indexPath.row * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [cell setReloadInterval:ui.reloadInterval];
            });
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
        case DuoUIWebUI: {
            DetailWebUICell *cell = [[tableView visibleCells] objectAtIndex:indexPath.row];
            [cell openWebUI];
            break;
        }
        default:
            break;
    }
}

@end
