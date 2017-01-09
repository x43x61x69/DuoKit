//
//  DetailSetterCell.m
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

#import "DetailSetterCell.h"

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
        [self reload];
        _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                  target:self
                                                selector:@selector(reload)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)reload
{
    if (_textField.isEditing) {
        return;
    }
    [_duo readValueWithKey:_key
         completionHandler:^(NSInteger api,
                             BOOL status,
                             double value,
                             NSString *result,
                             NSError *error)
     {
         if (status) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 _value = value;
                 if (_textField) {
                     _textField.text = [NSString stringWithFormat:@"%.*f", 2, _value];
                 }
             });
         } else {
             if (error) {
                 NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error debugDescription]);
             } else {
                 NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
             }
         }
     }];
}

- (void)dismissKeyboard
{
    [self endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:_textField]) {
        [_duo updateValue:[_textField.text floatValue]
                  withKey:_key
        completionHandler:^(NSInteger api,
                            BOOL status,
                            double value,
                            NSString *result,
                            NSError *error)
         {
             if (status) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     _value = value;
                 });
             } else {
                 
                 if (error) {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error debugDescription]);
                 } else {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
                 }
             }
         }];
    }
}

@end
