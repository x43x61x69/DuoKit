//
//  MTKDuoBrowser.m
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

#ifdef DEBUG
#define LOGD(fmt, ...) NSLog(@"[DuoKit DEBUG] %s: " fmt "\n", __FUNCTION__ , ## __VA_ARGS__ );
#else
#define LOGD(...)
#endif

#define kLinkItSmartServicePrefix @"LinkIt"

#import "MTKDuoBrowser.h"
#import "NSNetService+Extension.h"

#pragma mark - MTKDuoBrowser

@interface MTKDuoBrowser () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
{
    NSString *searchingDomain;
    NSString *searchingService;
}

@property (nonatomic, strong) NSMutableArray        *domains;
@property (nonatomic, strong) NSMutableArray        *services;
@property (nonatomic, strong) NSNetServiceBrowser   *netServiceBrowser;
@property (nonatomic, strong) NSNetService          *netService;

@end

@implementation MTKDuoBrowser

@synthesize netServiceBrowser = _netServiceBrowser;

static MTKDuoBrowser *sharedInstance = nil;

+ (MTKDuoBrowser *)sharedInstance
{
    @synchronized (self) {
        if (!sharedInstance) {
            sharedInstance = [MTKDuoBrowser new];
        }
    }
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.netServiceBrowser = [NSNetServiceBrowser new];
    }
    return self;
}

- (void)dealloc
{
    if (_netServiceBrowser) {
        _netServiceBrowser = nil;
    }
}

#pragma mark - NSNetServiceBrowser

- (void)setNetServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
{
    searchingDomain  = nil;
    searchingService = nil;
    
    if (_netService) {
        [_netService stop];
        _netService = nil;
    }
    
    if (_netServiceBrowser) {
        [_netServiceBrowser stop];
    }
    
    _netServiceBrowser = netServiceBrowser;
    
    if (_netServiceBrowser) {
        LOGD(@"New!");
        _services   = [NSMutableArray new];
        _domains    = [NSMutableArray new];
        _netServiceBrowser.delegate = self;
    } else {
        LOGD(@"Clean up!");
        _netService = nil;
        _services   = nil;
        _domains    = nil;
    }
}

- (NSNetServiceBrowser *)netServiceBrowser
{
    return _netServiceBrowser;
}

#pragma mark - Methods

- (BOOL)searchForBrowsableDomains
{
    if (!_netServiceBrowser) {
        return NO;
    }
    [_netServiceBrowser searchForBrowsableDomains];
    return YES;
}

- (BOOL)searchForRegistrationDomains
{
    if (!_netServiceBrowser) {
        return NO;
    }
    [_netServiceBrowser searchForRegistrationDomains];
    return YES;
}

- (void)domainsDidChanged
{
    LOGD(@"Domains: %@", _domains);
    if (_delegate &&
        [_delegate respondsToSelector:@selector(domainsDidChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate domainsDidChanged:_domains];
        });
    }
}

- (BOOL)searchForServicesOfType:(NSString *)type
                       inDomain:(NSString *)domain
{
    
    NSNetServiceBrowser *newBrowser = [NSNetServiceBrowser new];
    if (!newBrowser) {
        return NO;
    }
    
    searchingService = type;
    searchingDomain  = domain;
    
    self.netServiceBrowser = newBrowser;
    [_netServiceBrowser searchForServicesOfType:type
                                       inDomain:domain];
    return YES;
}

- (void)servicesDidChanged
{
    LOGD(@"Services: %@", _services);
    if (_delegate &&
        [_delegate respondsToSelector:@selector(servicesDidChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate servicesDidChanged:_services];
        });
    }
    if (_delegate &&
        [_delegate respondsToSelector:@selector(duoListDidChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableArray *list = [NSMutableArray new];
            
            for (NSNetService *service in _services) {
                
                MTKDuo *duo;
                
                if ((duo = [[MTKDuo alloc] initWithService:service])) {
                    [list addObject:duo];
                }
            }
            
            [_delegate duoListDidChanged:list];
        });
    }
}

- (BOOL)resolveService:(NSNetService *)service withTimeout:(NSTimeInterval)timeout
{
    if (!service) {
        return NO;
    }
    _netService = service;
    _netService.delegate = self;
    
    [_netService resolveWithTimeout:timeout];
    return YES;
}

- (void)didResolveInstance:(NSNetService *)service
{
    LOGD(@"Service: %@", service);
    _netService = service;
    if (_delegate &&
        [_delegate respondsToSelector:@selector(didResolveInstance:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate didResolveInstance:service];
        });
    }
    if (_delegate &&
        [_delegate respondsToSelector:@selector(didResolveDuo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MTKDuo *duo;
            
            if ((duo = [[MTKDuo alloc] initWithService:service])) {
                [_delegate didResolveDuo:duo];
            }
        });
        
    }
    
    if (_delegate &&
        [_delegate respondsToSelector:@selector(didResolveInstance:name:domain:type:host:addresses:v4Addresses:v6Addresses:port:path:user:password:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]];
            
            [_delegate didResolveInstance:service
                                     name:[service name]
                                   domain:[service domain]
                                     type:[service type]
                                     host:[service hostName]
                                addresses:[service addressStrings]
                              v4Addresses:[service v4AddressStrings]
                              v6Addresses:[service v6AddressStrings]
                                     port:[service port]
                                     path:[MTKDuo stringFromTXTDict:dict withKey:@"path"]
                                     user:[MTKDuo stringFromTXTDict:dict withKey:@"u"]
                                 password:[MTKDuo stringFromTXTDict:dict withKey:@"p"]];
        });
        
    }
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
            didFindDomain:(NSString *)domainString
               moreComing:(BOOL)moreComing
{
    if (![_domains containsObject:domainString]){
        [_domains addObject:domainString];
    }
    if (!moreComing) {
        [self domainsDidChanged];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
          didRemoveDomain:(NSString *)domainString
               moreComing:(BOOL)moreComing
{
    [_domains removeObject:domainString];
    if (!moreComing) {
        [self domainsDidChanged];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing
{
    if (_netService &&
        [service isEqual:_netService]) {
        [_netService stop];
        _netService = nil;
    }
    
    [_services addObject:service];
    if (!moreComing) {
        [self servicesDidChanged];
    }}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing
{
    [_services removeObject:service];
    if (!moreComing) {
        [self servicesDidChanged];
    }
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    if (_delegate &&
        [_delegate respondsToSelector:@selector(willSearchForServicesOfType:inDomain:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate willSearchForServicesOfType:searchingService
                                          inDomain:searchingDomain];
        });
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    if (_delegate &&
        [_delegate respondsToSelector:@selector(didNotSearchForServicesOfType:inDomain:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate didNotSearchForServicesOfType:searchingService
                                            inDomain:searchingDomain
                                               error:errorDict];
        });
    }
    
    searchingService = nil;
    searchingDomain  = nil;
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    if (_delegate &&
        [_delegate respondsToSelector:@selector(didStopSearch:inDomain:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate didStopSearch:searchingService
                            inDomain:searchingDomain];
        });
    }
    
    searchingService = nil;
    searchingDomain  = nil;
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    [self didResolveInstance:sender];
}

- (void)netService:(NSNetService *)sender
     didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    if (_delegate &&
        [_delegate respondsToSelector:@selector(didNotResolveInstance:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate didNotResolveInstance:sender
                                       error:errorDict];
        });
    }
    
    if (_delegate &&
        [_delegate respondsToSelector:@selector(didNotResolveDuo:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MTKDuo *duo;
            
            if ((duo = [[MTKDuo alloc] initWithService:sender])) {
                [_delegate didNotResolveDuo:duo
                                      error:errorDict];
            }
        });
    }
    
    if (_netService) {
        [_netService stop];
        _netService = nil;
    }
}

@end
