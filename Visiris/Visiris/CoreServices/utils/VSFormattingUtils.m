//
//  VSFormattingUtils.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFormattingUtils.h"


@implementation VSFormattingUtils

#pragma mark - Functions

+(NSString*) formatedTimeStringFromMilliseconds:(double)milliseconds formatString:(NSString*) formatString{
    int tenth = floor(milliseconds/10);
    int seconds = floor(tenth/100);
    int minutes = floor(seconds / 60);
    int hours = floor(minutes/60);
    
    tenth = (round(tenth - seconds*100));
    seconds = round(seconds - minutes * 60);
    minutes = round(minutes - hours*60);
    
    NSString *componentFormat = @"%02d";
    
    NSString *formatedTimeString = [formatString stringByReplacingOccurrencesOfString:@"HH" withString:[NSString stringWithFormat:componentFormat,hours]];
    formatedTimeString = [formatedTimeString stringByReplacingOccurrencesOfString:@"mm" withString:[NSString stringWithFormat:componentFormat,minutes]];
    formatedTimeString = [formatedTimeString stringByReplacingOccurrencesOfString:@"ss" withString:[NSString stringWithFormat:componentFormat,seconds]];
    formatedTimeString = [formatedTimeString stringByReplacingOccurrencesOfString:@"tt" withString:[NSString stringWithFormat:componentFormat,tenth]];
    
//    [NSString stringWithFormat:@"%02d:%02d:%02d:%02d",hours,minutes,seconds,tenth];
    
    return formatedTimeString;
}

+(NSString*) formatedFileSizeStringFromByteValue:(int)bytes{
    float sizeValue = bytes / 1024;
    
    if(sizeValue < 1024){
        return [NSString stringWithFormat:@"%.2f KB", sizeValue];
    }
    
    sizeValue /= 1024;
    if(sizeValue < 1024){
        return [NSString stringWithFormat:@"%.2f MB", sizeValue];
    }
    
    sizeValue /= 1024;
    return [NSString stringWithFormat:@"%.2f GB", sizeValue];
}

@end
