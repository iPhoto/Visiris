//
//  VSDeviceRepresentation.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 04.10.12.
//
//

#import "VSDeviceRepresentation.h"

#import "VSDevice.h"

#import "VSCoreServices.h"

@interface VSDeviceRepresentation()

@property (strong) NSString *ID;
@property (strong) NSString *name;

@end

@implementation VSDeviceRepresentation

@synthesize name    = _name;
@synthesize ID      = _ID;

#pragma mark - Init

-(id) initWithDeviceToRepresent:(VSDevice *)device{
    if(self = [self initWithID:device.ID andName:device.name]){
    }
    
    return self;
}

-(id) initWithID:(NSString*) ID andName:(NSString *)name{
    if(self = [super init]){
        self.name = name;
        self.ID = ID;
    }
    
    return self;
}

#pragma mark - NSCoding Implementation

-(id) initWithCoder:(NSCoder *)aDecoder{
    self.name = [aDecoder decodeObjectForKey:@"drName"];
    self.ID = [aDecoder decodeObjectForKey:@"drID"];
    
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:@"drName"];
    [aCoder encodeObject:self.ID forKey:@"drID"];
}

#pragma mark- NSPasteboardWriting Implementation

-(NSArray*) writableTypesForPasteboard:(NSPasteboard *)pasteboard{
    static NSArray* writeableTypes = nil;
    
    if(!writeableTypes){
        writeableTypes = [NSArray arrayWithObject:VSDevicePasteboardType];
    }
    
    return writeableTypes;
}

-(id) pasteboardPropertyListForType:(NSString *)type{
    if([type isEqualToString:VSDevicePasteboardType]){
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    return self.name;
}

#pragma mark- NSPasteboardWriting Implementation

+(NSArray*) readableTypesForPasteboard:(NSPasteboard *)pasteboard{
    static NSArray* readableTypes = nil;
    
    if(!readableTypes){
        readableTypes = [NSArray arrayWithObject:VSDevicePasteboardType];
    }
    
    return readableTypes;
}

+(NSPasteboardReadingOptions) readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard{
    
    if ([type isEqualToString:VSDevicePasteboardType]){
        return NSPasteboardReadingAsKeyedArchive;
    }
    return NSPasteboardReadingAsData;
}

-(id) initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type{
    
    return nil;
}


@end
