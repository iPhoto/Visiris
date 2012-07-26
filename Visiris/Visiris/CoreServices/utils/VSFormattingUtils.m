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

+(NSString*) formatedTimeStringFromMilliseconds:(double)milliseconds{
    int seconds = floor(milliseconds/1000);
    int minutes = floor(seconds / 60);
    int hours = floor(minutes/60);
    
    seconds = round(seconds - minutes * 60);
    minutes = round(minutes - hours*60);
    
    NSString* secondsString = [NSString stringWithFormat:@"%@%d",seconds < 10 ? @"0" : @"",seconds];
    NSString* minutesString = [NSString stringWithFormat:@"%@%d",minutes < 10 ? @"0" : @"",minutes];
    NSString* hoursString = [NSString stringWithFormat:@"%@%d",hours < 10 ? @"0" : @"",hours];
    
    NSString* formatedTimeString = [NSString stringWithFormat:@"%@:%@:%@",hoursString,minutesString,secondsString];
    
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
