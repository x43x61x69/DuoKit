//
//  DetailSetterCell.m
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

#import "DetailSetterCell.h"
#import "Common.h"

@interface DetailSetterCell ()
{
    NSUUID *actionUUID;
}

@end

@implementation DetailSetterCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _textField.delegate = self;
    
    UIBarButtonItem *flexibleItem
    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil
                                                    action:nil];
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(dismissKeyboard)];
    UIToolbar *inputToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(.0f, .0f,
                                                                           self.frame.size.width,
                                                                           44.f)];
    
    [inputToolbar setItems:@[flexibleItem, doneButton] animated:NO];
    _textField.inputAccessoryView = inputToolbar;
}

- (void)setReloadInterval:(NSTimeInterval)interval
{
    if (_timer) {
        [_timer invalidate];
    }
    if (interval) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                  target:self
                                                selector:@selector(reload)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)reload
{
    if (_textField.isEditing || actionUUID) {
        return;
    }
    if (_pin) {
        _title.textColor = [UIColor darkTextColor];
        _indicator.color = kColorUIDefault;
        [_indicator startAnimating];
        [_duo readAnalogPin:_pin
          completionHandler:^(NSInteger api,
                              BOOL status,
                              DuoPin pin,
                              DuoPinValue value,
                              NSString *result,
                              NSError *error)
         {
             [_indicator stopAnimating];
             if (status) {
                 _value = value;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (_textField &&
                         !_textField.isEditing &&
                         !actionUUID) {
                         switch (_valueType) {
                             case DuoIntType:
                                 _textField.text = [NSString stringWithFormat:@"%ld", lroundf(_value)];
                                 break;
                             case DuoDoubleType:
                                 _textField.text = [NSString stringWithFormat:@"%.*f", 2, _value];
                                 break;
                             default:
                                 break;
                         }
                     }
                 });
             } else {
                 _title.textColor = kColorBase;
                 if (error) {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
                 } else {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
                 }
             }
         }];
    } else if (_key) {
        _title.textColor = [UIColor darkTextColor];
        _indicator.color = kColorUIDefault;
        [_indicator startAnimating];
        [_duo readValueWithKey:_key
             completionHandler:^(NSInteger api,
                                 BOOL status,
                                 double value,
                                 NSString *stringValue,
                                 NSString *result,
                                 NSError *error)
         {
             [_indicator stopAnimating];
             if (status) {
                 switch (_valueType) {
                     case DuoStringType:
                         _stringValue = stringValue;
                         break;
                     default:
                         _value = value;
                         break;
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (_textField &&
                         !_textField.isEditing &&
                         !actionUUID) {
                         switch (_valueType) {
                             case DuoIntType:
                                 _textField.text = [NSString stringWithFormat:@"%ld", lroundf(_value)];
                                 break;
                             case DuoDoubleType:
                                 _textField.text = [NSString stringWithFormat:@"%.*f", 2, _value];
                                 break;
                             case DuoStringType:
                                 _textField.text = _stringValue;
                                 break;
                             default:
                                 break;
                         }
                     }
                 });
             } else {
                 _title.textColor = kColorBase;
                 if (error) {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
                 } else {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
                 }
             }
         }];
    }
}

- (void)dismissKeyboard
{
    [self endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:_textField]) {
        NSUUID *thisAction = [NSUUID UUID];
        actionUUID = thisAction;
        __unsafe_unretained typeof(self) weakSelf = self;
        if (_pin) {
            _title.textColor = [UIColor darkTextColor];
            _indicator.color = kColorBase;
            [_indicator startAnimating];
            [_duo setPinType:DuoSetPinAnalog
                         pin:_pin
                       value:[_textField.text floatValue]
           completionHandler:^(NSInteger api,
                               BOOL status,
                               DuoPin pin,
                               DuoPinValue value,
                               DuoPinMode mode,
                               NSString *result,
                               NSError *error)
             {
                 [weakSelf.indicator stopAnimating];
                 if (!status) {
                     weakSelf.title.textColor = kColorBase;
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (!_textField.isEditing &&
                             thisAction == actionUUID) {
                             _value = value;
                         }
                     });
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
                 } else {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
                 }
                 
                 if (thisAction == actionUUID) {
                     actionUUID = nil;
                 }
             }];
        } else if (_key) {
            _title.textColor = [UIColor darkTextColor];
            _indicator.color = kColorBase;
            [_indicator startAnimating];
            [_duo updateValue:_valueType == DuoStringType ? 0 : [_textField.text floatValue]
                  stringValue:_valueType == DuoStringType ? _textField.text : nil
                      withKey:_key
            completionHandler:^(NSInteger api,
                                BOOL status,
                                double value,
                                NSString *stringValue,
                                NSString *result,
                                NSError *error)
             {
                 [_indicator stopAnimating];
                 if (status) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (!_textField.isEditing &&
                             thisAction == actionUUID) {
                             switch (_valueType) {
                                 case DuoStringType:
                                     _stringValue = stringValue;
                                     break;
                                 default:
                                     _value = value;
                                     break;
                             }
                         }
                     });
                 } else {
                     _title.textColor = kColorBase;
                     if (error) {
                         NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
                     } else {
                         NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
                     }
                 }
                 
                 if (thisAction == actionUUID) {
                     actionUUID = nil;
                 }
             }];
        }
    }
}

@end
