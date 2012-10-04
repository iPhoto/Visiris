//
//  VSDeviceRepresentation.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 04.10.12.
//
//

#import <Foundation/Foundation.h>

@class VSDevice;

@interface VSDeviceRepresentation : NSObject<NSPasteboardWriting,NSPasteboardReading, NSCoding>

@property (strong, readonly) NSString *ID;
@property (strong, readonly) NSString *name;

-(id) initWithDeviceToRepresent:(VSDevice*) device;

@end
