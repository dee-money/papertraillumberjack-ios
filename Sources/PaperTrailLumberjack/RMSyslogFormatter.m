//
//  RMSyslogFormatter.m
//  Pods
//
//  Created by Malayil Philip George on 5/7/14.
//  Copyright (c) 2014 Rogue Monkey Technologies & Systems Private Limited. All
//  rights reserved.
//
//

#import "RMSyslogFormatter+Private.h"
#import "NSString+RMPaperTrailLumberjack.h"

static NSString* const RMAppUUIDKey = @"RMAppUUIDKey";

@implementation RMSyslogFormatter

@synthesize machineName=_machineName;
@synthesize programName=_programName;

-(id) init
{
    self = [super init];
    if (self) {
        _syslogRFCType = RMSyslogRFCType5424;
        _machineName = nil;
        _programName = nil;
    }
    
    return self;
}

- (NSString*)formatLogMessage:(DDLogMessage*)logMessage
{
    switch (_syslogRFCType) {
        case RMSyslogRFCType5424:
            return [self formatWithRFC5424:logMessage];
            break;
        case RMSyslogRFCType3164:
        default:
            return [self formatWithRFC3164:logMessage];
            break;
    }
}

-(NSString*) formatWithRFC3164:(DDLogMessage*) logMessage
{
    NSString* msg = logMessage.message;
    
    NSString* logLevel = [self rfc3164LogLevel:logMessage];
    NSString* timestamp = [self rfc3164Timestamp:logMessage];
    
    NSString* function = [self formatFunctionName:logMessage.function];
    NSString* log =
    [NSString stringWithFormat:@"<%@>%@ %@ %@: %@ %@@%@:%lu] \"%@\"",
     logLevel, timestamp, self.machineName,
     self.programName, logMessage.threadID, logMessage.fileName,
     function, (unsigned long)logMessage.line, msg];
    
    
    return log;
}

-(NSString*) formatWithRFC5424:(DDLogMessage*) logMessage
{
    NSInteger priValue = [self rfc5424PRIValue:logMessage];
    NSString* timestamp = [self rfc5424Timestamp:logMessage];
    NSString* function = [self formatFunctionName:logMessage.function];
    NSString* header = [NSString stringWithFormat:@"<%ld>1 %@ %@ %@ - -", (long) priValue, timestamp, self.machineName, self.programName];
    
    NSString* message = [NSString stringWithFormat:@"\357\273\277%@ %@@%@:%lu %@", logMessage.threadID, logMessage.fileName, function, (unsigned long) logMessage.line, logMessage.message];
    
    NSString* log = [NSString stringWithFormat:@"%@ - %@", header, message];
    
    return log;
}

-(NSString*) rfc3164Timestamp:(DDLogMessage*) logMessage
{
    static NSDateFormatter* dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd HH:mm:ss"];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    });
    
    return [dateFormatter stringFromDate:logMessage.timestamp];
}

-(NSString*) rfc5424Timestamp:(DDLogMessage*) logMessage
{
    static NSDateFormatter* dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    
    return [dateFormatter stringFromDate:logMessage.timestamp];
}

-(NSString*) rfc3164LogLevel:(DDLogMessage*) logMessage
{
    NSString* logLevel = @"";
    switch (logMessage.flag) {
        case DDLogFlagError:
            logLevel = @"11";
            break;
        case DDLogFlagWarning:
            logLevel = @"12";
            break;
        case DDLogFlagInfo:
            logLevel = @"14";
            break;
        case DDLogFlagDebug:
            logLevel = @"15";
            break;
        case DDLogFlagVerbose:
            logLevel = @"15";
            break;
        default:
            logLevel = @"15";
            break;
    }
    
    return logLevel;
}

-(NSInteger) rfc5424PRIValue:(DDLogMessage*) logMessage
{
    NSInteger facilityValue = 1;
    NSInteger severityValue = 0;
    switch (logMessage.flag) {
        case DDLogFlagError:
            severityValue = 3;
            break;
        case DDLogFlagWarning:
            severityValue = 4;
            break;
        case DDLogFlagInfo:
            severityValue = 6;
            break;
        case DDLogFlagDebug:
        default:
            severityValue = 7;
            break;
    }
    
    return facilityValue * 8 + severityValue;
}

-(NSString*) formatFunctionName:(NSString*) functionName
{
    NSString* formattedName = functionName;
    if ([formattedName hasPrefix:@"-"]) {
        formattedName = [formattedName substringFromIndex:1];
    }
    if ([formattedName hasSuffix:@"]"]) {
        formattedName = [formattedName substringToIndex:formattedName.length-1];
    }
    
    return formattedName;
}

-(void) setMachineName:(NSString *)machineName
{
    _machineName = [machineName stringByRemovingAllWhitespace];
}

- (NSString*)machineName
{
    if (_machineName == nil) {
        // We will generate and use a app-specific UUID to maintain user privacy.
        NSString* uuid =
        [[NSUserDefaults standardUserDefaults] stringForKey:RMAppUUIDKey];
        if (uuid == nil) {
            uuid = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setObject:uuid
                                                      forKey:RMAppUUIDKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        _machineName = uuid;
    }
    
    return _machineName;
}

-(void) setProgramName:(NSString *)programName
{
    _programName = [programName stringByRemovingAllWhitespace];
}

- (NSString*)programName
{
    if (_programName == nil) {
        NSString* bundleName = [[[NSBundle mainBundle] localizedInfoDictionary]
                                objectForKey:@"CFBundleDisplayName"];
        if (bundleName == nil) {
            bundleName = [[[NSBundle mainBundle] infoDictionary]
                          objectForKey:@"CFBundleDisplayName"];
        }
        
        // Remove all whitespace characters from appname
        _programName = [bundleName stringByRemovingAllWhitespace];
    }
    
    return _programName;
}

@end
