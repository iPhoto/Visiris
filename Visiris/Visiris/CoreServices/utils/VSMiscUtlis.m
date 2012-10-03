//
//  VSMiscUtlis.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 03.10.12.
//
//

#import "VSMiscUtlis.h"

@implementation VSMiscUtlis


+ (NSString*) stringWithUUID {
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString	*uuidString = (__bridge NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}

@end
