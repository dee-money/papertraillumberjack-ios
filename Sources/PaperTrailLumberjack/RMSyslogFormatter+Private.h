//
//  RMSyslogFormatter+Private.h
//  Pods
//
//  Created by George Malayil Philip on 30/01/16.
//  Copyright (c) 2016 Rogue Monkey Technologies & Systems Private Limited. All
//  rights reserved.
//
//

#import "RMSyslogFormatter.h"

@interface RMSyslogFormatter () {
    
}

/**
 Can be used to override machine name as a constant (instead of using a UUID per device)
 */
@property (nonatomic, copy, nullable) NSString* machineName;

/**
 Can be used to override program name, instead of getting it from the bundle name
 */
@property (nonatomic, copy, nullable) NSString* programName;

@end
