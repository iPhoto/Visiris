//
//  VSDeviceManager.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDeviceManager.h"

#import "VSDeviceLoader.h"

#import "VSCoreServices.h"

@interface VSDeviceManager()

@property VSDeviceLoader *deviceLoader;

@end


@implementation VSDeviceManager

static NSString *devicesFolder;

static NSURL* devicesFolderURL;

@synthesize devices = _devices;

+(void) initialize{
    NSString *applicationSupportFolder = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *visirisFolderName = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*) kCFBundleNameKey];
    
    
    
    devicesFolder = [NSString stringWithFormat:@"%@/%@/devices",applicationSupportFolder,visirisFolderName];
    devicesFolderURL = [NSURL fileURLWithPath:devicesFolder];
    NSError *error;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:devicesFolder withIntermediateDirectories:YES attributes:nil error:&error];
    
    if(error){
        DDLogInfo(@"%@",error);
    }
}

-(id) init{
    if(self = [super init]){
        [self loadExisitingDevices];

    }
    
    return self;
}

-(void) loadExisitingDevices{

    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:devicesFolder];
    
    [dirEnum skipDescendants];
    
    NSString *file;
    
    while (file = [dirEnum nextObject]) {
        if([[file  pathExtension] isEqualToString:@"xml"]){
            [self loadDeviceFromXMLFile:[NSString stringWithFormat:@"%@/%@",devicesFolder, file]];
        }
    }
}

-(void) loadDeviceFromXMLFile:(NSString*) filePath{

}



- (BOOL)addDevice:(VSDevice *)newDevice
{
    BOOL didAddDevice = NO;
    
    if (newDevice) {
        [self.devices addObject:newDevice];
        didAddDevice = YES;
    }else{
        DDLogError(@"Error adding new device: newDevice was nil - this will fail");
    }
    
    return didAddDevice;
}

- (NSUInteger)numberOfDevices
{
    return _devices.count;
}
@end
