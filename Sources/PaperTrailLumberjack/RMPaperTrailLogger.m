//
//  PaperTrailLumberJack.m
//  PaperTrailLumberJack
//
//  Created by Malayil Philip George on 5/1/14.
//  Copyright (c) 2014 Rogue Monkey Technologies & Systems Private Limited. All rights reserved.
//

#import "RMPaperTrailLogger.h"
#import "RMSyslogFormatter+Private.h"

@interface RMPaperTrailLogger () {
    GCDAsyncSocket *_tcpSocket;
    GCDAsyncUdpSocket *_udpSocket;
}

@property (nonatomic, strong) GCDAsyncSocket *tcpSocket;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

@end

@implementation RMPaperTrailLogger

@synthesize host = _host;
@synthesize port = _port;
@synthesize useTcp = _useTcp;
@synthesize useTLS = _useTLS;

@synthesize tcpSocket = _tcpSocket;
@synthesize udpSocket = _udpSocket;

+(RMPaperTrailLogger *) sharedInstance
{
    static dispatch_once_t pred = 0;
    static RMPaperTrailLogger *_sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
        RMSyslogFormatter *logFormatter = [[RMSyslogFormatter alloc] init];
        _sharedInstance.logFormatter = logFormatter;
        _sharedInstance.useTcp = YES;
        _sharedInstance.useTLS = YES;
        _sharedInstance.syslogRFCType = RMSyslogRFCType5424;
    });
    
    return _sharedInstance;
}

-(void) dealloc {
    [self disconnect];
}

#pragma mark - Accessors
-(void) setMachineName:(NSString *)machineName
{
    _machineName = machineName;
    if ([self.logFormatter isKindOfClass:[RMSyslogFormatter class]]) {
        RMSyslogFormatter* syslogFormatter = (RMSyslogFormatter*)_logFormatter;
        syslogFormatter.machineName = machineName;
    }
}

-(void) setProgramName:(NSString *)programName
{
    _programName = programName;
    if ([self.logFormatter isKindOfClass:[RMSyslogFormatter class]]) {
        RMSyslogFormatter* syslogFormatter = (RMSyslogFormatter*)_logFormatter;
        syslogFormatter.programName = programName;
    }
}

-(void) setSyslogRFCType:(RMSyslogRFCType)syslogRFCType
{
    _syslogRFCType = syslogRFCType;
    if ([self.logFormatter isKindOfClass:[RMSyslogFormatter class]]) {
        RMSyslogFormatter* syslogFormatter = (RMSyslogFormatter*)_logFormatter;
        syslogFormatter.syslogRFCType = syslogRFCType;
    }
}

#pragma mark - Networking Implementation
-(void) disconnect
{
    if (self.tcpSocket != nil) {
        [self.tcpSocket disconnect];
        self.tcpSocket = nil;
    } else if (self.udpSocket != nil) {
        [self.udpSocket close];
        self.udpSocket = nil;
    }
}

-(void) logMessage:(DDLogMessage *)logMessage
{
    if (self.host == nil || self.host.length == 0 || self.port == 0)
        return;
    
    NSString *logMsg = logMessage.message;
    if (logMsg == nil) {
        logMsg = @"";
    }
    
    if (_logFormatter) {
        logMsg = [_logFormatter formatLogMessage:logMessage];
    }
    
    //Check if last character is newLine
    unichar lastChar = [logMsg characterAtIndex:logMsg.length-1];
    if (![[NSCharacterSet newlineCharacterSet] characterIsMember:lastChar]) {
        logMsg = [NSString stringWithFormat:@"%@\n", logMsg];
    }
    
    if (!self.useTcp) {
        [self sendLogOverUdp:logMsg];
    } else {
        [self sendLogOverTcp:logMsg];
    }
}

-(void) sendLogOverUdp:(NSString *) message
{
    if (message == nil || message.length == 0)
        return;
    
    if (self.udpSocket == nil) {
        GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.udpSocket = udpSocket;
    }
    
    NSData *logData = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.udpSocket sendData:logData toHost:self.host port:self.port withTimeout:-1 tag:1];
}

-(void) sendLogOverTcp:(NSString *) message
{
    if (message == nil || message.length == 0)
        return;
    
    @synchronized(self) {
        if (self.tcpSocket == nil) {
            GCDAsyncSocket *tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            self.tcpSocket = tcpSocket;
            [self connectTcpSocket];
        }
    }
    
    NSData *logData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.tcpSocket writeData:logData withTimeout:-1 tag:1];
}

-(void) connectTcpSocket
{
    if (self.host == nil || self.port == 0)
        return;
    
    NSError *error = nil;
    [self.tcpSocket connectToHost:self.host onPort:self.port error:&error];
    if (error != nil) {
        NSLog(@"Error connecting to host: %@", error);
        return;
    }
    
    if (self.useTLS) {
#ifdef DEBUG
        NSLog(@"Starting TLS");
#endif
        [self.tcpSocket startTLS:nil];
    }
}

#pragma mark - GCDAsyncDelegate methods

#ifdef DEBUG

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Socket did connect to host");
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    NSLog(@"Socket did secure");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error
{
    NSLog(@"Socket did disconnect. Error: %@", error);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"Socket did write data");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"UDP Socket did write data");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"UDP Socket Error: %@", error.localizedDescription);
}

#endif

@end
