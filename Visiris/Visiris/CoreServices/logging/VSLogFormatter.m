//
//  VSLogFormatter.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSLogFormatter.h"

@interface VSLogFormatter ()

@property (strong) NSDateFormatter      *dateFormatter;

@end

@implementation VSLogFormatter
@synthesize dateFormatter=_dateFormatter;

- (id)init
{
    self = [super init];
    
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"HH:mm:ss:SSS"];
     }
    
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSMutableString *formattedLogMessage = [NSMutableString stringWithFormat:@"[%@ %s] l:%i - %@ | %@", [logMessage fileName], logMessage->function, logMessage->lineNumber, [self.dateFormatter stringFromDate:logMessage->timestamp], logMessage->logMsg];
    
    return formattedLogMessage;
}

@end
