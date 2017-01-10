//
//  DetailSwitchCell.m
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

#import "DetailSwitchCell.h"

@interface DetailSwitchCell ()
{
    NSUUID *actionUUID;
}

@end

@implementation DetailSwitchCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _pinSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    
    [_pinSwitch addTarget:self
                   action:@selector(switchDidChange:)
         forControlEvents:UIControlEventValueChanged];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryView = _pinSwitch;
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
    if (_pinSwitch.isTouchInside || actionUUID) {
        return;
    }
    [_duo readDigitalPin:_pin
       completionHandler:^(NSInteger api,
                           BOOL status,
                           DuoPin pin,
                           DuoPinValue value,
                           DuoPinMode mode,
                           NSString *result,
                           NSError *error)
     {
         if (status) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (_pinSwitch &&
                     !_pinSwitch.isTouchInside &&
                     !actionUUID) {
                     [_pinSwitch setOn:(value == DuoPinHigh) animated:YES];
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

- (void)switchDidChange:(UISwitch *)sender
{
    if ([sender isEqual:_pinSwitch]) {
        [sender setOn:[sender isOn] animated:YES];
        NSUUID *thisAction = [NSUUID UUID];
        actionUUID = thisAction;
        [_duo setPinType:DuoSetPinDigital
                     pin:_pin
                   value:sender.on ? DuoPinHigh : DuoPinLow
       completionHandler:^(NSInteger api,
                           BOOL status,
                           DuoPin pin,
                           DuoPinValue value,
                           DuoPinMode mode,
                           NSString *result,
                           NSError *error)
         {
             if (!status) {
                 if (!_pinSwitch.isTouchInside &&
                     thisAction == actionUUID) {
                     [sender setOn:!sender.on animated:YES];
                 }
                 NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error debugDescription]);
             } else {
                 NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
             }
         }];
    }
}

@end
