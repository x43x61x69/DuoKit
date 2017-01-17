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
#import "DetailAddItemTVC.h"
#import "DetailWebUICell.h"
#import "DetailSwitchCell.h"
#import "DetailSetterCell.h"
#import "DetailSliderCell.h"

@interface DetailTVC () <UITextFieldDelegate, DetailAddItemDelegate>

@end

@implementation DetailTVC

- (void)loadView
{
    [super loadView];
    
    _layout = [NSMutableArray new];
    
    UIBarButtonItem *addButton
    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                    target:self
                                                    action:@selector(addButtonAction:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backAction:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (id cell in self.tableView.visibleCells) {
        if ([cell respondsToSelector:@selector(setReloadInterval:)]) {
            [cell setReloadInterval:0];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:kDetailAddItemSegueIdentifer]) {
        DetailAddItemTVC *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Pre-Defined by Arduino";
        case 1:
            return @"User Defined";
        default:
            return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_duo.layout.count > 0) + (_layout.count > 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _duo.layout.count;
        case 1:
            return _layout.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DuoUI *ui;
    switch (indexPath.section) {
        case 1:
            ui = [_layout objectAtIndex:indexPath.row];
            break;
        default:
            ui = [_duo.layout objectAtIndex:indexPath.row];
            break;
    }
    
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
            [cell.pinSwitch setOn:ui.value animated:NO];
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
            cell.valueType = ui.valueType;
            cell.key = ui.key;
            switch (ui.valueType) {
                case DuoIntType:
                    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                    cell.value = ui.value;
                    cell.textField.text = [NSString stringWithFormat:@"%ld", lroundf(ui.value)];
                    break;
                case DuoDoubleType:
                    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
                    cell.value = ui.value;
                    cell.textField.text = [NSString stringWithFormat:@"%.*f", 2, ui.value];
                    break;
                case DuoStringType:
                    cell.textField.keyboardType = UIKeyboardTypeASCIICapable;
                    cell.stringValue = ui.stringValue;
                    cell.textField.text = ui.stringValue;
                    break;
                default:
                    break;
            }
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
            cell.pin = ui.pin;
            if (ui.key) cell.key = ui.key;
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
    
    NSArray<DuoUI *> *source;
    switch (indexPath.section) {
        case 1:
            source = _layout;
            break;
        default:
            source = _duo.layout;
            break;
    }
    
    switch ([source objectAtIndex:indexPath.row].type) {
        case DuoUIWebUI: {
            DetailWebUICell *cell = [[tableView visibleCells] objectAtIndex:indexPath.row];
            [cell openWebUI];
            break;
        }
        default:
            break;
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

- (IBAction)addButtonAction:(id)sender
{
    [self performSegueWithIdentifier:kDetailAddItemSegueIdentifer sender:sender];
}

#pragma mark - DetailAddItemDelegate

- (void)newItemAdded:(DuoUI *)newUI
{
    [_layout addObject:newUI];
    [self.tableView reloadData];
}

@end
