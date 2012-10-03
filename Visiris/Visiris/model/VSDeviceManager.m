//
//  VSDeviceManager.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDeviceManager.h"

#import "VSDeviceLoader.h"
#import "VSDevice.h"
#import "VSDeviceParameter.h"

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
        self.devices = [[NSMutableArray alloc]init];
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
    NSError *error;

    NSURL *xmlURL = [NSURL fileURLWithPath:filePath];
    
    NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithContentsOfURL: xmlURL options:0 error:&error];
    
    NSXMLElement *deviceNode = [xmlDocument rootElement];
    
    NSString *name = [[deviceNode attributeForName:@"name"] stringValue];

    VSDevice *device = [[VSDevice alloc] initWithID:[VSMiscUtlis stringWithUUID] andName:name];
    
    NSArray *parameterNodes = [deviceNode elementsForName:@"parameter"];
    
    for(NSXMLElement *parameterNode in parameterNodes){
        
        NSString *name= [[parameterNode attributeForName:@"name"] stringValue];
        NSString *oscPath= [[parameterNode attributeForName:@"oscPath"] stringValue];
        
        float fromValue = [[[parameterNode attributeForName:@"fromValue"] stringValue] floatValue];
        float toValue = [[[parameterNode attributeForName:@"toValue"] stringValue] floatValue];
        
        VSDeviceParameter *deviceParameter = [[VSDeviceParameter alloc] initWithName:name
                                                                             oscPath:oscPath
                                                                           fromValue:fromValue
                                                                             toValue:toValue];
        
        [device addParametersObject:deviceParameter];
    }
    
    [self addDevice:device];

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

-(VSDevice*)objectInDevicesAtIndex:(NSUInteger)index{
    return [self.devices objectAtIndex:index];
}

- (NSUInteger)numberOfDevices
{
    return _devices.count;
}
@end
