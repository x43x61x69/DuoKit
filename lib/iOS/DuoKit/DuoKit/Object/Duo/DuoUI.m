//
//  DuoUI.m
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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "DuoUI.h"

@implementation DuoUI

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.type           = [decoder decodeIntegerForKey:@"type"];
        self.name           = [decoder decodeObjectForKey:@"name"];
        self.key            = [decoder decodeObjectForKey:@"key"];
        self.pin            = [decoder decodeIntegerForKey:@"pin"];
        self.value          = [decoder decodeDoubleForKey:@"value"];
        self.stringValue    = [decoder decodeObjectForKey:@"stringValue"];
        self.valueType      = [decoder decodeIntegerForKey:@"valueType"];
        self.minimumValue   = [decoder decodeDoubleForKey:@"minimumValue"];
        self.maximumValue   = [decoder decodeDoubleForKey:@"maximumValue"];
        self.color          = [decoder decodeObjectForKey:@"color"];
        self.reloadInterval = [decoder decodeDoubleForKey:@"reloadInterval"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:_type            forKey:@"type"];
    [encoder encodeObject:_name             forKey:@"name"];
    [encoder encodeObject:_key              forKey:@"key"];
    [encoder encodeInteger:_pin             forKey:@"pin"];
    [encoder encodeDouble:_value            forKey:@"value"];
    [encoder encodeObject:_stringValue      forKey:@"stringValue"];
    [encoder encodeInteger:_valueType       forKey:@"valueType"];
    [encoder encodeDouble:_minimumValue     forKey:@"minimumValue"];
    [encoder encodeDouble:_maximumValue     forKey:@"maximumValue"];
    [encoder encodeObject:_color            forKey:@"color"];
    [encoder encodeDouble:_reloadInterval   forKey:@"reloadInterval"];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (!dictionary ||
        ![dictionary objectForKey:@"type"] ||
        ![[dictionary objectForKey:@"type"] integerValue]) {
        return nil;
    }
    
    if (self = [super init]) {
        self.type = [[dictionary objectForKey:@"type"] integerValue];
        if ([dictionary objectForKey:@"name"])
            self.name = [dictionary objectForKey:@"name"];
        if ([dictionary objectForKey:@"key"])
            self.key = [dictionary objectForKey:@"key"];
        if ([dictionary objectForKey:@"pin"])
            self.pin = [[dictionary objectForKey:@"pin"] integerValue];
        if ([dictionary objectForKey:@"valueType"])
            self.valueType = [[dictionary objectForKey:@"valueType"] integerValue];
        switch (self.valueType) {
            case DuoIntType:
            case DuoDoubleType:
                if ([dictionary objectForKey:@"value"])
                    self.value = [[dictionary objectForKey:@"value"] doubleValue];
                break;
            case DuoStringType:
                if ([dictionary objectForKey:@"value"])
                    self.stringValue = [dictionary objectForKey:@"value"];
                break;
            default:
                break;
        }
        if ([dictionary objectForKey:@"min"])
            self.minimumValue = [[dictionary objectForKey:@"min"] doubleValue];
        if ([dictionary objectForKey:@"max"])
            self.maximumValue = [[dictionary objectForKey:@"max"] doubleValue];
        if ([dictionary objectForKey:@"color"])
            self.color = UIColorFromRGB([[dictionary objectForKey:@"color"] integerValue]);
        if ([dictionary objectForKey:@"interval"]) {
            self.reloadInterval = MAX(0.f, [[dictionary objectForKey:@"interval"] doubleValue]);
            if (self.reloadInterval) {
                self.reloadInterval = MAX(3.f, self.reloadInterval);
            }
        }
    }
    return self;
}

@end
