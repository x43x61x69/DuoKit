//
//  Duo.m
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

#define kDefaultTimeout .0f
#define kApi            @"api"
#define kStatus         @"status"
#define kOK             @"ok"
#define kFailed         @"failed"
#define kPingCommand    @"ping"
#define kDigitalCommand @"digital"
#define kAnalogCommand  @"analog"
#define kModeCommand    @"mode"
#define kReadCommand    @"read"
#define kListCommand    @"list"
#define kUpdateCommand  @"update"
#define kRemoveCommand  @"remove"
#define kPin            @"pin"
#define kValue          @"value"
#define kValueType      @"valueType"
#define kMode           @"mode"
#define kMessage        @"message"
#define kVersion        @"version"
#define kCount          @"count"
#define kKeys           @"keys"
#define kProfile        @"profile"
#define kLayout         @"layout"

#import "Duo.h"
#import "NSNetService+Extension.h"

@implementation Duo

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.service        = [decoder decodeObjectForKey:@"service"];
        self.name           = [decoder decodeObjectForKey:@"name"];
        self.domain         = [decoder decodeObjectForKey:@"domain"];
        self.type           = [decoder decodeObjectForKey:@"type"];
        self.host           = [decoder decodeObjectForKey:@"host"];
        self.v4Addresses    = [decoder decodeObjectForKey:@"v4Addresses"];
        self.v6Addresses    = [decoder decodeObjectForKey:@"v6Addresses"];
        self.path           = [decoder decodeObjectForKey:@"path"];
        self.user           = [decoder decodeObjectForKey:@"user"];
        self.password       = [decoder decodeObjectForKey:@"password"];
        self.port           = [decoder decodeIntegerForKey:@"port"];
        self.profile        = [decoder decodeObjectForKey:@"profile"];
        self.layout         = [decoder decodeObjectForKey:@"layout"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_service      forKey:@"service"];
    [encoder encodeObject:_name         forKey:@"name"];
    [encoder encodeObject:_domain       forKey:@"domain"];
    [encoder encodeObject:_type         forKey:@"type"];
    [encoder encodeObject:_host         forKey:@"host"];
    [encoder encodeObject:_v4Addresses  forKey:@"v4Addresses"];
    [encoder encodeObject:_v6Addresses  forKey:@"v6Addresses"];
    [encoder encodeObject:_path         forKey:@"path"];
    [encoder encodeObject:_user         forKey:@"user"];
    [encoder encodeObject:_password     forKey:@"password"];
    [encoder encodeInteger:_port        forKey:@"port"];
    [encoder encodeObject:_profile      forKey:@"profile"];
    [encoder encodeObject:_layout       forKey:@"layout"];
}

- (instancetype)initWithService:(NSNetService *)service
{
    if (!service) {
        return nil;
    }
    
    if (self = [super init]) {
        
        NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]];
        
        self.service     = service;
        self.name        = [service name];
        self.domain      = [service domain];
        self.type        = [service type];
        self.host        = [service hostName];
        self.v4Addresses = [service v4AddressStrings];
        self.v6Addresses = [service v6AddressStrings];
        self.port        = [service port];
        self.path        = [[self class] stringFromTXTDict:dict withKey:@"path"];
        self.user        = [[self class] stringFromTXTDict:dict withKey:@"u"];
        self.password    = [[self class] stringFromTXTDict:dict withKey:@"p"];
    }
    
    return self;
}

#pragma mark - Methods

+ (NSString *)stringFromTXTDict:(NSDictionary *)dict withKey:(NSString *)key
{
    NSData      *data;
    NSString    *result = nil;
    if ((data = [dict objectForKey:key])) {
        result = [[NSString alloc] initWithData:data
                                       encoding:NSUTF8StringEncoding];
    }
    return result;
}

- (NSDictionary *)dictionaryWithJSONData:(NSData *)data
                                   error:(NSError * _Nullable *)error
{
    if (!data) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingMutableContainers
                                             error:error];
}

- (void)dataTaskWithPath:(NSString *)path timeout:(NSTimeInterval)timeout completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.timeoutInterval = timeout ? timeout : 60.f;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/arduino/%@",
                                        self.host,
                                        path ? path : @""]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data,
                                                         NSURLResponse *response,
                                                         NSError *error)
      {
          completionHandler(data, response, error);
      }] resume];
}

#pragma mark - RESTful API
#pragma mark Ping
- (void)isDeviceReadyWithApi:(NSInteger)apiVersion completionHandler:(void (^)(NSInteger api, BOOL isReady, NSString *profile, NSArray *layout, NSString *errorMessage))completionHandler
{
    [self commandWithPath:kPingCommand
        completionHandler:^(NSInteger api,
                            BOOL status,
                            NSDictionary *result,
                            NSError *error)
     {
         if (status) {
             BOOL apiCheck = apiVersion >= api;
             NSString *profile = [result objectForKey:kProfile];
             NSArray *layouts = [result objectForKey:kLayout];
             dispatch_async(dispatch_get_main_queue(),^{
                 completionHandler(api, status && apiCheck, profile, layouts, !apiCheck ? @"Please update your client library to use with this code." : nil);
             });
         } else {
             NSString *message;
             if (error) {
                 message = [error localizedDescription];
             } else {
                 message = [result objectForKey:kMessage];
             }
             dispatch_async(dispatch_get_main_queue(),^{
                 completionHandler(api, status, nil, nil, message);
             });
         }
     }];
}
#pragma mark Set Pin
- (void)setPinType:(DuoSetPinType)type pin:(DuoPin)pin value:(DuoPinValue)value completionHandler:(void (^)(NSInteger api, BOOL status, DuoPin pin, DuoPinValue value, DuoPinMode mode, NSString *result, NSError *error))completionHandler
{
    NSString *path;
    switch (type) {
        case DuoSetPinDigital:
            path = kDigitalCommand;
            break;
        case DuoSetPinAnalog:
            path = kAnalogCommand;
            break;
        case DuoSetPinMode:
            path = kModeCommand;
            break;
        default:
            return;
    }
    
    path = [NSString stringWithFormat:@"%@/%d/%d",
            path,
            pin,
            value];
    
    [self commandWithPath:path
        completionHandler:^(NSInteger api,
                            BOOL status,
                            NSDictionary *result,
                            NSError *error)
     {
         if (status) {
             DuoPin pin = [[result objectForKey:kPin] integerValue];
             DuoPinValue value = [[result objectForKey:kValue] integerValue];
             switch (type) {
                 case DuoSetPinDigital:
                 case DuoSetPinMode: {
                     DuoPinValue mode = [[result objectForKey:kMode] integerValue];
                     completionHandler(api, status, pin, value, mode, nil, nil);
                     break;
                 }
                 case DuoSetPinAnalog: {
                     completionHandler(api, status, pin, value, DuoPinNone, nil, nil);
                     break;
                 }
                 default:
                     return;
             }
         } else {
             if (result) {
                 DuoPin pin = [[result objectForKey:kPin] integerValue];
                 NSString *message = [result objectForKey:kMessage];
                 completionHandler(api, status, pin, 0, DuoPinNone, message, error);
             } else {
                 completionHandler(api, status, 0, 0, DuoPinNone, nil, error);
             }
         }
     }];
}

#pragma mark Read Digital Pin
- (void)readDigitalPin:(DuoPin)pin completionHandler:(void (^)(NSInteger api, BOOL status, DuoPin pin, DuoPinValue value, DuoPinMode mode, NSString *result, NSError *error))completionHandler
{
    NSString *path = [NSString stringWithFormat:kDigitalCommand @"/%d",
                      pin];
    
    [self commandWithPath:path
        completionHandler:^(NSInteger api,
                            BOOL status,
                            NSDictionary *result,
                            NSError *error)
     {
         if (status) {
             DuoPin pin = [[result objectForKey:kPin] integerValue];
             DuoPinValue mode = [[result objectForKey:kMode] integerValue];
             DuoPinValue value = [[result objectForKey:kValue] integerValue];
             completionHandler(api, status, pin, value, mode, nil, nil);
         } else {
             if (result) {
                 DuoPin pin = [[result objectForKey:kPin] integerValue];
                 NSString *message = [result objectForKey:kMessage];
                 completionHandler(api, status, pin, 0, DuoPinNone, message, error);
             } else {
                 completionHandler(api, status, 0, 0, DuoPinNone, nil, error);
             }
         }
     }];
}

#pragma mark Read Analog Pin
- (void)readAnalogPin:(DuoPin)pin completionHandler:(void (^)(NSInteger api, BOOL status, DuoPin pin, DuoPinValue value, NSString *result, NSError *error))completionHandler
{
    NSString *path = [NSString stringWithFormat:kAnalogCommand @"/%d",
                      pin];
    
    [self commandWithPath:path
        completionHandler:^(NSInteger api,
                            BOOL status,
                            NSDictionary *result,
                            NSError *error)
     {
         if (status) {
             DuoPin pin = [[result objectForKey:kPin] integerValue];
             DuoPinValue value = [[result objectForKey:kValue] integerValue];
             completionHandler(api, status, pin, value, nil, nil);
         } else {
             if (result) {
                 DuoPin pin = [[result objectForKey:kPin] integerValue];
                 NSString *message = [result objectForKey:kMessage];
                 completionHandler(api, status, pin, 0, message, error);
             } else {
                 completionHandler(api, status, 0, 0, nil, error);
             }
         }
     }];
}

#pragma mark Read Value
- (void)readValueWithKey:(NSString *)key completionHandler:(void (^)(NSInteger api, BOOL status, double value, NSString *stringValue, NSString *result, NSError *error))completionHandler
{
    NSString *path = [NSString stringWithFormat:kReadCommand @"/%@",
                      key];
    
    [self commandWithPath:path
        completionHandler:^(NSInteger api,
                            BOOL status,
                            NSDictionary *result,
                            NSError *error)
     {
         if (status) {
             DuoObjectType type = [[result objectForKey:kValueType] integerValue];
             switch (type) {
                 case DuoIntType:
                 case DuoDoubleType: {
                     double _value = [[result objectForKey:kValue] doubleValue];
                     completionHandler(api, status, _value, nil, nil, nil);
                     break;
                 }
                 case DuoStringType: {
                     NSString *_value = [result objectForKey:kValue];
                     completionHandler(api, status, 0, _value, nil, nil);
                     break;
                 }
                 default: {
                     completionHandler(api, status, 0, nil, nil, nil);
                     break;
                 }
             }
         } else {
             if (result) {
                 NSString *message = [result objectForKey:kMessage];
                 completionHandler(api, status, 0, nil, message, error);
             } else {
                 completionHandler(api, status, 0, nil, nil, error);
             }
         }
     }];
}

#pragma mark List Value Keys
- (void)listKeysWithCompletionHandler:(void (^)(NSInteger api, BOOL status, NSInteger count, NSArray *keys, NSError *error))completionHandler
{
    [self commandWithPath:kListCommand
        completionHandler:^(NSInteger api,
                            BOOL status,
                            NSDictionary *result,
                            NSError *error)
     {
         if (status) {
             NSInteger count = [[result objectForKey:kCount] integerValue];
             NSArray *keys = [result objectForKey:kKeys];
             completionHandler(api, status, count, keys, nil);
         } else {
             completionHandler(api, status, -1, nil, error);
         }
     }];
}

#pragma mark Update Value
- (void)updateValue:(double)value stringValue:(NSString *)stringValue withKey:(NSString *)key completionHandler:(void (^)(NSInteger api, BOOL status, double value, NSString *stringValue, NSString *result, NSError *error))completionHandler
{
    NSData *stringData;
    if (stringValue) {
        stringData = [stringValue dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    }
    NSString *path = [NSString stringWithFormat:kUpdateCommand @"/%@/%@",
                      key,
                      stringValue ? stringData ? [NSString stringWithFormat:@"%ld/%@",
                                                  stringData.length,
                                                  [stringData base64EncodedStringWithOptions:0]] : @"" :
                      [NSString stringWithFormat:@"%.*f", 2, value]];
    
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, path);
    
    [self commandWithPath:path
        completionHandler:^(NSInteger api,
                            BOOL status,
                            NSDictionary *result,
                            NSError *error)
     {
         if (status) {
             DuoObjectType type = [[result objectForKey:kValueType] integerValue];
             switch (type) {
                 case DuoIntType:
                 case DuoDoubleType: {
                     double _value = [[result objectForKey:kValue] doubleValue];
                     completionHandler(api, status, _value, nil, nil, nil);
                     break;
                 }
                 case DuoStringType: {
                     NSString *_value = [result objectForKey:kValue];
                     completionHandler(api, status, 0, _value, nil, nil);
                     break;
                 }
                 default: {
                     completionHandler(api, status, 0, nil, nil, nil);
                     break;
                 }
             }
         } else {
             if (result) {
                 NSString *message = [result objectForKey:kMessage];
                 completionHandler(api, status, 0, nil, message, error);
             } else {
                 completionHandler(0, status, 0, nil, nil, error);
             }
         }
     }];
}

#pragma mark Remove Value Key
- (void)removeKey:(NSString *)key completionHandler:(void (^)(NSInteger api, BOOL status, NSString *result, NSError *error))completionHandler
{
    NSString *path = [NSString stringWithFormat:kRemoveCommand @"/%@",
                      key];
    
    [self commandWithPath:path
        completionHandler:^(NSInteger api,
                            BOOL status,
                            NSDictionary *result,
                            NSError *error)
     {
         if (status) {
             completionHandler(api, status, nil, nil);
         } else {
             if (result) {
                 NSString *message = [result objectForKey:kMessage];
                 completionHandler(api, status, message, error);
             } else {
                 completionHandler(api, status, nil, error);
             }
         }
     }];
}

#pragma mark Shared
- (void)commandWithPath:(NSString *)path completionHandler:(void (^)(NSInteger api, BOOL status, NSDictionary *result, NSError *error))completionHandler
{
    [self dataTaskWithPath:path
                   timeout:kDefaultTimeout
         completionHandler:^(NSData *data,
                             NSURLResponse *response,
                             NSError *error)
     {
         if (error) {
             dispatch_async(dispatch_get_main_queue(),^{
                 completionHandler(0, NO, nil, error);
             });
         } else if (response) {
             NSError *err;
             NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];
             if (err) {
                 NSString *e = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 if ([e hasPrefix:@"Could not connect to YunServer"]) {
                     dispatch_async(dispatch_get_main_queue(),^{
                         completionHandler(0, NO, @{kMessage : @"Bridge was not available.\n\nPlease make sure you have setup YunBridge correctly and wait until both MPU and MCU were fully initialized."}, nil);
                     });
                 } else {
                     NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     dispatch_async(dispatch_get_main_queue(),^{
                         completionHandler(0, NO, @{kMessage : message ? message : @"Error"}, err);
                     });
                 }
             } else {
                 NSInteger api = [[result objectForKey:kApi] integerValue];
                 BOOL status = [[result objectForKey:kStatus] isEqualToString:kOK];
                 dispatch_async(dispatch_get_main_queue(),^{
                     dispatch_async(dispatch_get_main_queue(),^{
                         completionHandler(api, status, result, nil);
                     });
                 });
             }
         }
     }];
}

@end
