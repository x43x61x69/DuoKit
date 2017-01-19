//
//  NSNetworkReachability.m
//  NSNetworkReachability
//
//  The MIT License (MIT)
//
//  Copyright © 2016 Zhi-Wei Cai (MediaTek Inc.). All rights reserved.
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

#import "NSNetworkReachability.h"

#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
// Requires SystemConfiguration.framework.
#import <SystemConfiguration/SCNetworkReachability.h>

@interface NSNetworkReachability ()
{
    SCNetworkReachabilityRef reachabilityRef;
}

@end

@implementation NSNetworkReachability

static NSNetworkReachability *sharedInstance = nil;

+ (NSNetworkReachability *)sharedInstance
{
    // Thread blocking to be sure for singleton instance
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [NSNetworkReachability new];
        }
    }
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        struct sockaddr_in nullAddr;
        bzero(&nullAddr, sizeof(nullAddr));
        nullAddr.sin_len    = sizeof(nullAddr);
        nullAddr.sin_family = AF_INET;
        reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&nullAddr);
        SCNetworkReachabilityContext context = {0, (__bridge void * _Nullable)(self), NULL, NULL, NULL};
        SCNetworkReachabilitySetCallback(reachabilityRef, SCNetworkReachabilityCallback, &context);
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, dispatch_queue_create("vg.vox.NetworkQueue", nil));
    }
    return self;
}

static void SCNetworkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
    NSNetworkReachabilityStatus status;
    
    if (!flags) {
        status = NotReachable;
    } else {
        BOOL isReachable     = ((flags & kSCNetworkFlagsReachable) != 0);
        BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
        
        if (isReachable && !needsConnection) {
            
            BOOL isWWANConnection = ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
            
            if (isWWANConnection) {
                status = ReachableViaWWAN;
            } else {
                status = ReachableViaWiFi;
            }
        } else {
            status = NotReachable;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNSNetworkReachabilityDidChangeNotification
                                                            object:sharedInstance
                                                          userInfo:@{kNSNetworkReachabilityStatus : @(status)}];
    });
}

#pragma mark - Network Connection

// When using simulators, turned on/off OS X's Internet for testing.
+ (NSNetworkReachabilityStatus)networkStatus
{
    struct sockaddr_in nullAddr;
    bzero(&nullAddr, sizeof(nullAddr));
    nullAddr.sin_len    = sizeof(nullAddr);
    nullAddr.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachabilityRef
    = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&nullAddr);
    
    SCNetworkReachabilityFlags flags;
    BOOL retrievedFlags = SCNetworkReachabilityGetFlags(reachabilityRef,
                                                        &flags);
    CFRelease(reachabilityRef);
    
    if (!retrievedFlags) {
        return NotReachable;
    }
    
    BOOL isReachable     = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    
    if (isReachable && !needsConnection) {
        
        BOOL isWWANConnection = ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
        
        if (isWWANConnection) {
            return ReachableViaWWAN;
        } else {
            return ReachableViaWiFi;
        }
    } else {
        return NotReachable;
    }
}

+ (BOOL)canAccessInternet
{
    switch ([self networkStatus]) {
        case ReachableViaWiFi:
        case ReachableViaWWAN:
            return YES;
        case NotReachable:
        default:
            break;
    }
    return NO;
}

@end
