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
    [_duo readValueWithKey:_key
         completionHandler:^(NSInteger api,
                             BOOL status,
                             double value,
                             NSString *result,
                             NSError *error)
     {
         if (status) {
             dispatch_async(dispatch_get_main_queue(), ^{
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

- (void)sliderDidEndEditng:(UISlider *)slider
{
    if ([slider isEqual:_slider]) {
        NSUUID *thisAction = [NSUUID UUID];
        actionUUID = thisAction;
        [_duo updateValue:_slider.value
                  withKey:_key
        completionHandler:^(NSInteger api,
                            BOOL status,
                            double value,
                            NSString *result,
                            NSError *error)
         {
             if (status) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (!_slider.isTouchInside &&
                         thisAction == actionUUID) {
                         [UIView animateWithDuration:.5f
                                               delay:.0f
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              [_slider setValue:value animated:YES];
                                          } completion:nil];
                     }
                 });
             } else {
                 
                 if (error) {
                     NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error debugDescription]);
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

@end
