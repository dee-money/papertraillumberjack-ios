//
//  RMSyslogFormats.h
//  PaperTrailLumberjack
//
//  Created by George Malayil Philip on 20/01/19.
//  Copyright © 2019 Rogue Monkey Technologies And Systems Private Limited. All rights reserved.
//

/**
 RFC 5424 is the newer messaging format, and, obsoletes RFC3164.
 */
typedef NS_ENUM(NSInteger, RMSyslogRFCType) {
    RMSyslogRFCType5424,
    RMSyslogRFCType3164
};
