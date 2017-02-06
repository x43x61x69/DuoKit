//
//  DetailSwitchCell.h
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

#define kDetailSwitchCellIdentifer  @"DetailSwitchCell"

#import <UIKit/UIKit.h>
#import <DuoKit/DuoKit.h>

@interface DetailSwitchCell : UITableViewCell

@property (nonatomic, strong) Duo *duo;
@property (nonatomic)         DuoPin pin;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UISwitch *pinSwitch;

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

- (void)setReloadInterval:(NSTimeInterval)interval;
- (void)reload;

@end
