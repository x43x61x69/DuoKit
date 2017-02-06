//
//  DetailPinModeTVC.m
//  DuoKit Browser
//
//  The MIT License (MIT)
//
//  Copyright © 2017 MediaTek Inc. All rights reserved.
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

#import "DetailPinModeTVC.h"
#import "DetailPinModeDefaultCell.h"
#import "DetailPinModeTypeCell.h"

typedef enum {
    DetailPinModeNone = 0,
    DetailPinModePin,
    DetailPinModeMode
} DetailPinModeKey;

@interface DetailPinModeTVC () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>


@property (nonatomic, strong) NSArray<NSNumber *> *layout;

@property (nonatomic, strong) NSMutableArray  *modeDataSource;
@property (nonatomic, strong) UIPickerView    *modePicker;

@property (nonatomic, strong) UITextField     *pinTextField;
@property (nonatomic, strong) UITextField     *modeTextField;

@end

@implementation DetailPinModeTVC

- (void)loadView
{
    [super loadView];
    
    _layout = @[@(DetailPinModePin),
                @(DetailPinModeMode)];
    
    _modeDataSource = [NSMutableArray arrayWithArray:@[@"Ouput", @"Input", @"Input Pullup"]];
    _modePicker = [UIPickerView new];
    _modePicker.dataSource = self;
    _modePicker.delegate = self;
    _modePicker.showsSelectionIndicator = YES;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Change Pin Mode";
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Enter a pin number, then select a new mode.";
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
    return _layout.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([[_layout objectAtIndex:indexPath.row] integerValue]) {
        case DetailPinModePin: {
            DetailPinModeDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailPinModeDefaultCellIdentifer
                                                                             forIndexPath:indexPath];
            cell.title.text = @"Pin Number";
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            _pinTextField = cell.textField;
            _pinTextField.delegate = self;
            
            UIBarButtonItem *flexibleItem
            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                            target:nil
                                                            action:nil];
            UIBarButtonItem *doneButton =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                          target:self
                                                          action:@selector(dissmissInputView:)];
            UIToolbar *inputToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(.0f, .0f,
                                                                                   self.tableView.contentSize.width,
                                                                                   44.f)];
            
            [inputToolbar setItems:@[flexibleItem, doneButton] animated:NO];
            cell.textField.inputAccessoryView = inputToolbar;
            return cell;
        }
        case DetailPinModeMode: {
            DetailPinModeTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailPinModeTypeCellIdentifer
                                                                          forIndexPath:indexPath];
            cell.textField.hideCaret = YES;
            
            cell.title.text = @"Pin Mode";
            [cell.textField setInputView:_modePicker];
            _modeTextField = cell.textField;
            _modeTextField.delegate = self;
            
            UIBarButtonItem *flexibleItem
            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                            target:nil
                                                            action:nil];
            UIBarButtonItem *doneButton =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                          target:self
                                                          action:@selector(dissmissModeInputView)];
            UIToolbar *inputToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(.0f, .0f,
                                                                                   self.tableView.contentSize.width,
                                                                                   44.f)];
            [inputToolbar setItems:@[flexibleItem, doneButton] animated:NO];
            cell.textField.inputAccessoryView = inputToolbar;
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
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _modePicker) {
        return _modeDataSource.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == _modePicker) {
        return _modeDataSource[row];
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == _modePicker) {
        _modeTextField.text = _modeDataSource[row];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _modeTextField) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _modeTextField) {
        BOOL shouldBeginEditing = _pinTextField.text.length && [_pinTextField.text integerValue] >= 0;
        if (!shouldBeginEditing) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:_pinTextField.text.length ? @"Error" : @"Missing Pin number"
                                                                           message:_pinTextField.text.length ? @"Invalid Pin number!" : @"Please enter a valid Pin number."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          if (_pinTextField) {
                                                                              _pinTextField.text = @"";
                                                                              [_pinTextField becomeFirstResponder];
                                                                          };
                                                                      });
                                                                  }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        return shouldBeginEditing;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (void)dissmissInputView:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    _modeTextField.text = @"";
    
    NSInteger pin = [_pinTextField.text integerValue];
    if (!_pinTextField.text.length || pin < 0) {
        _pinTextField.text = @"";
        [_pinTextField becomeFirstResponder];
    } else {
        [self readModeOfPin:pin];
    }
}

- (void)dissmissModeInputView
{
    NSInteger selected = [_modePicker selectedRowInComponent:0];
    _modeTextField.text = _modeDataSource[selected];
    [_modeTextField resignFirstResponder];
    if ([self checkTextFields]) {
        [self modeDidChangeForPin:[_pinTextField.text integerValue]];
    }
}

- (BOOL)checkTextFields
{
    if (!_pinTextField.text.length || [_pinTextField.text integerValue] < 0) {
        _pinTextField.text = @"";
        [_pinTextField becomeFirstResponder];
        return NO;
    } else if ([_modePicker selectedRowInComponent:0] < DuoPinOutput || [_modePicker selectedRowInComponent:0] > DuoPinInputPullup) {
        [_modeTextField becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (void)readModeOfPin:(DuoPin)pin
{
    self.tableView.userInteractionEnabled = NO;
    [self showActivityView];
    [_duo readDigitalPin:pin
       completionHandler:^(NSInteger api,
                           BOOL status,
                           DuoPin pin,
                           DuoPinValue value,
                           DuoPinMode mode,
                           NSString *result,
                           NSError *error)
     {
         [self hideActivityView];
         if (status) {
             if (mode >= 0 && mode < [_modePicker numberOfRowsInComponent:0]) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [_modePicker selectRow:mode inComponent:0 animated:YES];
                     _modeTextField.text = _modeDataSource[mode];
                 });
             }
         } else {
             NSString *err;
             if (error) {
                 err = [error localizedDescription];
                 NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
             } else {
                 err = result;
                 NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
             }
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                            message:err
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action) {
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [self readModeOfPin:pin];
                                                                       });
                                                                   }];
             UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action) {
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           if (_pinTextField) {
                                                                               [_pinTextField becomeFirstResponder];
                                                                           };
                                                                       });
                                                                   }];
             [alert addAction:retryAction];
             [alert addAction:defaultAction];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self presentViewController:alert animated:YES completion:nil];
                 _modeTextField.text = @"";
             });
         }
         self.tableView.userInteractionEnabled = YES;
     }];
}

- (void)modeDidChangeForPin:(DuoPin)pin
{
    self.tableView.userInteractionEnabled = NO;
    [self showActivityView];
    __unsafe_unretained typeof(self) weakSelf = self;
    [_duo setPinType:DuoSetPinMode
                 pin:pin
               value:[_modePicker selectedRowInComponent:0]
   completionHandler:^(NSInteger api,
                       BOOL status,
                       DuoPin pin,
                       DuoPinValue value,
                       DuoPinMode mode,
                       NSString *result,
                       NSError *error)
     {
         [weakSelf hideActivityView];
         if (status) {
             if (mode >= 0 && mode < [_modePicker numberOfRowsInComponent:0]) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [weakSelf.modePicker selectRow:mode inComponent:0 animated:YES];
                     weakSelf.modeTextField.text = weakSelf.modeDataSource[mode];
                 });
             }
         } else {
             NSString *err;
             if (error) {
                 err = [error localizedDescription];
                 NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
             } else {
                 err = result;
                 NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
             }
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                            message:err
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         [weakSelf modeDidChangeForPin:pin];
                                                                     });
                                                                 }];
             UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action) {
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [weakSelf.modeTextField becomeFirstResponder];
                                                                       });
                                                                   }];
             [alert addAction:retryAction];
             [alert addAction:defaultAction];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf presentViewController:alert animated:YES completion:nil];
             });
         }
         weakSelf.tableView.userInteractionEnabled = YES;
     }];
}

@end
