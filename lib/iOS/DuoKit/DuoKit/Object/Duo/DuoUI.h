//
//  DuoUI.h
//  DuoKit
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : uint8_t {
    DuoUINone  = 0,
    DuoUIWebUI,
    DuoUISwitch,
    DuoUISetter,
    DuoUIGetter,
    DuoUISlider
} DuoUIType;

typedef enum : uint8_t {
    DuoNoneType  = 0,
    DuoIntType,
    DuoDoubleType,
    DuoStringType
} DuoObjectType;

@interface DuoUI : NSObject

@property (nonatomic)       DuoUIType       type;
@property (nonatomic, copy) NSString        *name;
@property (nonatomic)       NSInteger       pin;
@property (nonatomic, copy) NSString        *key;
@property (nonatomic)       double          value;
@property (nonatomic, copy) NSString        *stringValue;
@property (nonatomic)       DuoObjectType   valueType;
@property (nonatomic)       double          minimumValue;
@property (nonatomic)       double          maximumValue;
@property (nonatomic, copy) UIColor         *color;
@property (nonatomic)       NSTimeInterval  reloadInterval;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
