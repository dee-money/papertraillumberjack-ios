//
//  PaperTrailLumberJack.h
//  PaperTrailLumberJack
//
//  Created by Malayil Philip George on 5/1/14.
//  Copyright (c) 2016 Rogue Monkey Technologies & Systems Private Limited. All
//  rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMSyslogFormats.h"

@import CocoaLumberjack;
@import CocoaAsyncSocket;

/**
 RMPaperTrailLogger is a custom logger (for CocoaLumberjack) that directs log
 output to your account on papertrailapp.com. It can log using TCP and UDP. On
 OS X, TLS is supported on TCP Connections. Currently, on iOS TCP connections
 only Plain-Text is supported. The default is UDP (which is always unencrypted).
 The logs are sent in a syslog format using RMSyslogFormatter. If you are going
 to provide a custom formatter, make sure that it formats messages that meets
 the syslog spec.
 */
@interface RMPaperTrailLogger : DDAbstractLogger <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>

/**
 The host to which logs should be sent. Ex. logs.papertrailapp.com
 */
@property (nonatomic, copy, nonnull) NSString* host;

/**
 The port on host to which we should connect. Ex. 9999
 */
@property (nonatomic, assign) NSUInteger port;

/**
 Can be used to override machine name as a constant (instead of using a UUID per device)
 */
@property (nonatomic, copy, nullable) NSString* machineName;

/**
 Can be used to override program name, instead of getting it from the bundle name
 */
@property (nonatomic, copy, nullable) NSString* programName;

/**
 Specifies whether we should connect via TCP. Default is `NO` (uses UDP)
 */
@property (nonatomic, assign) BOOL useTcp;

/**
 Specifies whether we should use TLS. Default is `YES`. This parameter applies
 only to TCP connections.
 */
@property (nonatomic, assign) BOOL useTLS;

/**
Specifies which RFC to follow for the syslog message format. We default to RFC 3164, so, as not to make a breaking change in newer versions of PapertrailLumberjack.
*/
@property (nonatomic, assign) RMSyslogRFCType syslogRFCType;

/**
 Returns a initialized singleton instance of this logger
 */
+ (RMPaperTrailLogger* _Nullable)sharedInstance;

@end
