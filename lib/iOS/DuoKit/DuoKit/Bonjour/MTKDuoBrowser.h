//
//  MTKDuoBrowser.h
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
#import "MTKDuo.h"

#pragma mark - Bonjour Service Types

// Apple QA1312: https://developer.apple.com/library/content/qa/qa1312/_index.html

#define kBonjourServiceTypeAFP                 @"_afpovertcp._tcp"     // AppleTalk Filing Protocol (AFP)
#define kBonjourServiceTypeNFS                 @"_nfs._tcp"            // Network File System (NFS)
#define kBonjourServiceTypeWEBDAV              @"_webdav._tcp"         // WebDAV File System (WEBDAV)
#define kBonjourServiceTypeFTP                 @"_ftp._tcp"            // File Transfer Protocol (FTP)
#define kBonjourServiceTypeSSH                 @"_ssh._tcp"            // Secure Shell (SSH)
#define kBonjourServiceTypeRemoteAppleEvents   @"_eppc._tcp"           // Remote AppleEvents
#define kBonjourServiceTypeHTTP                @"_http._tcp"           // Hypertext Transfer Protocol (HTTP)
#define kBonjourServiceTypeTELNET              @"_telnet._tcp"         // Remote Login (TELNET)
#define kBonjourServiceTypeLinePrinter         @"_printer._tcp"        // Line Printer Daemon (LPD/LPR)
#define kBonjourServiceTypeIPP                 @"_ipp._tcp"            // Internet Printing Protocol (IPP)
#define kBonjourServiceTypePDL                 @"_pdl-datastream._tcp" // PDL Data Stream (Port 9100)
#define kBonjourServiceTypeRemoteIOUSBPrinter  @"_riousbprint._tcp"    // Remote I/O USB Printer Protocol
#define kBonjourServiceTypeDAAP                @"_daap._tcp"           // Digital Audio Access Protocol (DAAP)
#define kBonjourServiceTypeDPAP                @"_dpap._tcp"           // Digital Photo Access Protocol (DPAP)
#define kBonjourServiceTypeiChat               @"_presence._tcp"       // iChat Instant Messaging Protocol
#define kBonjourServiceTypeImageCaptureSharing @"_ica-networking._tcp" // Image Capture Sharing
#define kBonjourServiceTypeAirPort             @"_airport._tcp"        // AirPort Base Station
#define kBonjourServiceTypeXserveRAID          @"_xserveraid._tcp"     // Xserve RAID
#define kBonjourServiceTypeDistributedCompiler @"_distcc._tcp"         // Distributed Compiler
#define kBonjourServiceTypeApplePasswordServer @"_apple-sasl._tcp"     // Apple Password Server
#define kBonjourServiceTypeWorkgroupManager    @"_workstation._tcp"    // Workgroup Manager
#define kBonjourServiceTypeServerAdmin         @"_servermgr._tcp"      // Server Admin
#define kBonjourServiceTypeRAOP                @"_raop._tcp"           // Remote Audio Output Protocol (RAOP)


@protocol MTKDuoBrowserDelegate <NSObject>

@optional

#pragma mark NSNetServiceBrowserDelegate

- (void)willSearchForServicesOfType:(NSString *)type inDomain:(NSString *)domain;
- (void)domainsDidChanged:(NSArray<NSString *> *)domains;
- (void)servicesDidChanged:(NSArray<NSNetService *> *)services;
- (void)duoListDidChanged:(NSArray<MTKDuo *> *)duoList;
- (void)didNotSearchForServicesOfType:(NSString *)type inDomain:(NSString *)domain error:(NSDictionary<NSString *,NSNumber *> *)errorDict;
- (void)didStopSearch:(NSString *)type inDomain:(NSString *)domain;

#pragma mark NSNetServiceDelegate

- (void)didResolveInstance:(NSNetService *)service;
- (void)didResolveDuo:(MTKDuo *)duo;
- (void)didResolveInstance:(NSNetService *)service name:(NSString *)name domain:(NSString *)domain type:(NSString *)type host:(NSString *)host addresses:(NSArray<NSString *> *)addresses v4Addresses:(NSArray<NSString *> *)v4Addresses v6Addresses:(NSArray<NSString *> *)v6Addresses port:(NSInteger)port path:(NSString *)path user:(NSString *)user password:(NSString *)password;
- (void)didNotResolveInstance:(NSNetService *)service error:(NSDictionary<NSString *,NSNumber *> *)errorDict;
- (void)didNotResolveDuo:(MTKDuo *)duo error:(NSDictionary<NSString *,NSNumber *> *)errorDict;

@end

@interface MTKDuoBrowser : NSObject

@property (nonatomic, assign) id <MTKDuoBrowserDelegate> delegate;

+ (MTKDuoBrowser *)sharedInstance;
- (BOOL)searchForBrowsableDomains;
- (BOOL)searchForRegistrationDomains;
- (BOOL)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain;
- (BOOL)resolveService:(NSNetService *)service withTimeout:(NSTimeInterval)timeout;

@end
