//
//  NSColor+VSColor.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 08.10.12.
//
//

#import "NSColor+VSColor.h"

@implementation NSColor (VSColor)

+(NSColor*) timelineRulerContentColor{
    return [NSColor darkGrayColor];
}

+(NSColor*) trackEvenBackgroundColor{
    return [NSColor lightGrayColor];
}

+(NSColor*) trackOddBackgroundColor{
    return [NSColor darkGrayColor];
}

+(NSColor*) mainTimelineTrackBackgroundColor{
    return [NSColor lightGrayColor];
}

+(NSColor*) trackLabelFontColor{
    return [NSColor whiteColor];
}

+(NSColor*) trackLabelBackgroundColor{
    return [NSColor darkGrayColor];
}

+(NSColor*) playheadGuiderColor{
    return [NSColor blackColor];
}

+(NSColor*) disclosureViewConteViewColor{
    return [NSColor lightGrayColor];
}

+(NSColor*) invisible{
    return [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
}

@end
