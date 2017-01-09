//
//  MTKDuo.h
//  DuoKit
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

#import <Foundation/Foundation.h>
#import "MTKDuoUI.h"

typedef uint8_t DuoPin;

typedef enum : uint8_t {
    DuoSetPinDigital   = 0,
    DuoSetPinAnalog    = 0x1,
    DuoSetPinMode      = 0x2
} DuoSetPinType;

typedef enum : uint8_t {
    DuoPinLow   = 0,
    DuoPinHigh  = 0x1
} DuoPinValue;

typedef enum : int8_t {
    DuoPinNone          = -1,
    DuoPinOutput        = 0,
    DuoPinInput         = 0x1,
    DuoPinInputPullup   = 0x2
} DuoPinMode;

@interface MTKDuo : NSObject

@property (nonatomic, strong)   NSNetService        *service;
@property (nonatomic, copy)     NSString            *name;
@property (nonatomic, copy)     NSString            *domain;
@property (nonatomic, copy)     NSString            *type;
@property (nonatomic, copy)     NSString            *host;
@property (nonatomic, copy)     NSArray<NSString *> *v4Addresses;
@property (nonatomic, copy)     NSArray<NSString *> *v6Addresses;
@property (nonatomic, copy)     NSString            *path;
@property (nonatomic, copy)     NSString            *user;
@property (nonatomic, copy)     NSString            *password;
@property (nonatomic, copy)     NSArray<MTKDuoUI *> *layout;

@property (nonatomic) NSInteger port;

- (instancetype)initWithService:(NSNetService *)service;
+ (NSString *)stringFromTXTDict:(NSDictionary *)dict withKey:(NSString *)key;
- (void)isDeviceReadyWithApi:(NSInteger)apiVersion completionHandler:(void (^)(NSInteger api, BOOL isReady, NSArray *layout, NSString *errorMessage))completionHandler;
- (void)setPinType:(DuoSetPinType)type pin:(DuoPin)pin value:(DuoPinValue)value completionHandler:(void (^)(NSInteger api, BOOL status, DuoPin pin, DuoPinValue value, DuoPinMode mode, NSString *result, NSError *error))completionHandler;
- (void)readDigitalPin:(DuoPin)pin completionHandler:(void (^)(NSInteger api, BOOL status, DuoPin pin, DuoPinValue value, DuoPinMode mode, NSString *result, NSError *error))completionHandler;
- (void)readAnalogPin:(DuoPin)pin completionHandler:(void (^)(NSInteger api, BOOL status, DuoPin pin, DuoPinValue value, NSString *result, NSError *error))completionHandler;
- (void)readValueWithKey:(NSString *)key completionHandler:(void (^)(NSInteger api, BOOL status, double value, NSString *result, NSError *error))completionHandler;
- (void)listKeysWithCompletionHandler:(void (^)(NSInteger api, BOOL status, NSInteger count, NSArray *keys, NSError *error))completionHandler;
- (void)updateValue:(double)value withKey:(NSString *)key completionHandler:(void (^)(NSInteger api, BOOL status, double value, NSString *result, NSError *error))completionHandler;
- (void)removeKey:(NSString *)key completionHandler:(void (^)(NSInteger api, BOOL status, NSString *result, NSError *error))completionHandler;

@end
