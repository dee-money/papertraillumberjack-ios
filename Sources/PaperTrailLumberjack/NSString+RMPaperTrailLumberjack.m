//
//  NSString+RMPaperTrailLumberjack.m
//  Pods
//
//  Created by George Malayil Philip on 30/01/16.
//
//

#import "NSString+RMPaperTrailLumberjack.h"

@implementation NSString (RMPaperTrailLumberjack)

-(NSString*) stringByRemovingAllWhitespace
{
    NSArray* components = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [components componentsJoinedByString:@""];
}

@end
