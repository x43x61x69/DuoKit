//
//  DetailSliderCell.m
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

#import "DetailSliderCell.h"

@interface DetailSliderCell ()
{
    NSUUID *actionUUID;
}

@end

@implementation DetailSliderCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [_slider addTarget:self
                action:@selector(sliderDidEndEditng:)
      forControlEvents:UIControlEventTouchUpInside];
    
    [_slider addTarget:self
                action:@selector(sliderValueDidChange:)
      forControlEvents:UIControlEventTouchDragInside];
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
    if (_slider.isTouchInside || actionUUID) {
        return;
    }
    if (_pin) {
        [_duo readAnalogPin:_pin
          completionHandler:^(NSInteger api,
                              BOOL status,
                              DuoPin pin,
                              DuoPinValue value,
                              NSString *result,
                              NSError *error)
         {
             if (status) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self reloadSliderValue:value];
                 });
             } else {
                 if (error) {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
                 } else {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
                 }
             }
         }];
    } else if (_key) {
        [_duo readValueWithKey:_key
             completionHandler:^(NSInteger api,
                                 BOOL status,
                                 double value,
                                 NSString *stringValue,
                                 NSString *result,
                                 NSError *error)
         {
             if (status) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self reloadSliderValue:value];
                 });
             } else {
                 if (error) {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
                 } else {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
                 }
             }
         }];
    }
}

- (void)reloadSliderValue:(CGFloat)value
{
    if (_slider &&
        !_slider.isTouchInside &&
        !actionUUID) {
        [UIView animateWithDuration:.5f
                              delay:.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_slider setValue:value animated:YES];
                         } completion:nil];
    }
}

- (void)sliderDidEndEditng:(UISlider *)slider
{
    if ([slider isEqual:_slider]) {
        
        _sliderValueLabel.text = @"";
        
        NSUUID *thisAction = [NSUUID UUID];
        actionUUID = thisAction;
        __unsafe_unretained typeof(self) weakSelf = self;
        if (_pin) {
            [_duo setPinType:DuoSetPinAnalog
                         pin:_pin
                       value:_slider.value
           completionHandler:^(NSInteger api,
                               BOOL status,
                               DuoPin pin,
                               DuoPinValue value,
                               DuoPinMode mode,
                               NSString *result,
                               NSError *error)
             {
                 if (!status) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [weakSelf updateSliderValue:value action:thisAction];
                     });
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
                 } else {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, result);
                 }
             }];
        } else if (_key) {
            [_duo updateValue:_slider.value
                  stringValue:nil
                      withKey:_key
            completionHandler:^(NSInteger api,
                                BOOL status,
                                double value,
                                NSString *stringValue,
                                NSString *result,
                                NSError *error)
             {
                 if (status) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self updateSliderValue:value action:thisAction];
                     });
                 } else {
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

- (void)updateSliderValue:(CGFloat)value action:(NSUUID *)action
{
    if (!_slider.isTouchInside &&
        action == actionUUID) {
        [UIView animateWithDuration:.5f
                              delay:.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_slider setValue:value animated:YES];
                         } completion:nil];
    }
}

- (void)sliderValueDidChange:(UISlider *)slider
{
    if ([slider isEqual:_slider]) {
        _sliderValueLabel.text = [NSString stringWithFormat:@"%ld", lroundf(_slider.value)];
    }
}


@end
