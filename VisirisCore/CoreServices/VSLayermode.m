//
//  VSLayermode.m
//  VisirisCore
//
//  Created by Edwin Guggenbichler on 9/12/12.
//
//

#import "VSLayermode.h"


static NSDictionary*    dic;


@interface VSLayermode()


@end


@implementation VSLayermode

+(void) initialize{
    dic = [NSDictionary dictionaryWithObjectsAndKeys:
           [NSNumber numberWithInt:1.0f], @"VSBlendModeNormal",
           [NSNumber numberWithInt:2.0f], @"VSBlendModeLighten",
           [NSNumber numberWithInt:3.0f], @"VSBlendModeDarken",
           [NSNumber numberWithInt:4.0f], @"VSBlendModeMultiply",
           [NSNumber numberWithInt:5.0f], @"VSBlendModeAverage",
           [NSNumber numberWithInt:6.0f], @"VSBlendModeAdd",
           [NSNumber numberWithInt:7.0f], @"VSBlendModeSubstract",
           [NSNumber numberWithInt:8.0f], @"VSBlendModeDifference",
           [NSNumber numberWithInt:9.0f], @"VSBlendModeNegation",
           [NSNumber numberWithInt:10.0f], @"VSBlendModeExclusion",
           [NSNumber numberWithInt:11.0f], @"VSBlendModeScreen",
           [NSNumber numberWithInt:12.0f], @"VSBlendModeOverlay",
           [NSNumber numberWithInt:13.0f], @"VSBlendModeSoftLight",
           [NSNumber numberWithInt:14.0f], @"VSBlendModeHardLight",
           [NSNumber numberWithInt:15.0f], @"VSBlendModeColorDodge",
           [NSNumber numberWithInt:16.0f], @"VSBlendModeColorBurn",
           [NSNumber numberWithInt:17.0f], @"VSBlendModeLinearDodge",
           [NSNumber numberWithInt:18.0f], @"VSBlendModeLinearBurn",
           [NSNumber numberWithInt:19.0f], @"VSBlendModeLinearLight",
           [NSNumber numberWithInt:20.0f], @"VSBlendModeVividLight",
           [NSNumber numberWithInt:21.0f], @"VSBlendModePinLight",
           [NSNumber numberWithInt:22.0f], @"VSBlendModeHardMix",
           [NSNumber numberWithInt:23.0f], @"VSBlendModeReflect",
           [NSNumber numberWithInt:24.0f], @"VSBlendModeGlow",
           [NSNumber numberWithInt:25.0f], @"VSBlendModePhoenix",
           [NSNumber numberWithInt:27.0f], @"VSBlendModeHue",
           [NSNumber numberWithInt:28.0f], @"VSBlendModeSaturation",
           [NSNumber numberWithInt:29.0f], @"VSBlendModeColor",
           [NSNumber numberWithInt:30.0f], @"VSBlendModeLuminosity",
           nil];
}

+ (float)floatFromString:(NSString *)string{
    return [(NSNumber *)[dic objectForKey:string] intValue];
}

@end
