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
#import "VSDeviceRepresentation.h"
#import "VSDeviceParameter.h"
#import "VSDeviceParameterUtils.h"

#import "VSCoreServices.h"

@interface VSDeviceManager()

@property VSDeviceLoader *deviceLoader;

@end


@implementation VSDeviceManager

static NSString *devicesFolder;

static NSURL* devicesFolderURL;

@synthesize devices = _devices;

#pragma mark - Init

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
        self.deviceRepresentations = [[NSMutableArray alloc] init];
        self.devices = [[NSMutableArray alloc]init];
        [self loadExisitingDevices];
    }
    
    return self;
}


#pragma mark - Methods

-(void) addDevicesObject:(VSDevice *)object{
    
    if (object) {
        [self.devices addObject:object];
        object.delegate = self;
        [self.deviceRepresentations addObject:[[VSDeviceRepresentation alloc] initWithDeviceToRepresent:object]];
    }else{
        DDLogError(@"Error adding new device: newDevice was nil - this will fail");
    }
}

-(VSDevice*)objectInDevicesAtIndex:(NSUInteger)index{
    return [self.devices objectAtIndex:index];
}

- (NSUInteger)numberOfDevices
{
    return _devices.count;
}

-(VSDeviceRepresentation*)objectInDeviceRepresentationsAtIndex:(NSUInteger)index{
    return [self.deviceRepresentations objectAtIndex:index];
}

-(VSDevice*) deviceRepresentedBy:(VSDeviceRepresentation*) deviceRepresentation{
    NSUInteger indexOfDevice = [self.devices indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSDevice class]]){
            if([((VSDevice*) obj).ID isEqualToString:deviceRepresentation.ID]){
                return YES;
            }
        }
        
        return NO;
    }];
    
    if(indexOfDevice != NSNotFound){
        return [self.devices objectAtIndex:indexOfDevice];
    }
    else{
        return nil;
    }
}

#pragma mark - VSDeviceDelegate Implementation

-(BOOL) registerDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device{
    BOOL result = NO;
    
    if([self delegateRespondsToSelector:@selector(registerValue:forAddress:atPort:)]){
        result = [self.deviceRegisitratingDelegate registerValue:[deviceParameter invocationForNewValue] forAddress:deviceParameter.oscPath atPort:deviceParameter.port];
    }
    
    return result;
}

-(BOOL) unregisterDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device{
    BOOL result = NO;
    
    if([self delegateRespondsToSelector:@selector(unregisterValue:forAddress:atPort:)]){
        result = [self.deviceRegisitratingDelegate unregisterValue:[deviceParameter invocationForNewValue] forAddress:deviceParameter.oscPath atPort:deviceParameter.port];
    }
    
    return result;
}


#pragma mark - Private Methods


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
        
        BOOL hasRange = NO;
        float fromValue, toValue = 0.0f;
        
        if([parameterNode attributeForName:@"fromValue"] && [parameterNode attributeForName:@"toValue"]){
            fromValue = [[[parameterNode attributeForName:@"fromValue"] stringValue] floatValue];
            toValue = [[[parameterNode attributeForName:@"toValue"] stringValue] floatValue];
            
            hasRange = YES;
        }
        NSUInteger port = [[[parameterNode attributeForName:@"port"] stringValue] integerValue];
        
        NSString *dataTypeName = [[parameterNode attributeForName:@"dataType"] stringValue];
        
        NSError *error;
        
        VSDeviceParameterDataype datatype = [VSDeviceParameterUtils deviceParameterDatatypeForString:dataTypeName andError:&error];
        
        if(!error){
            VSDeviceParameter *deviceParameter = nil;
            if(hasRange){
                deviceParameter = [[VSDeviceParameter alloc] initWithName:name
                                                                   ofType:datatype
                                                                  oscPath:oscPath
                                                                   atPort:port
                                                                fromValue:fromValue
                                                                  toValue:toValue];
            }
            else{
                deviceParameter  = [[VSDeviceParameter alloc] initWithName:name
                                                                    ofType:datatype
                                                                   oscPath:oscPath
                                                                    atPort:port];
            }
            
            
            [device addParametersObject:deviceParameter];
        }
        else{
            DDLogError(@"%@",error);
        }
        
        
    }
    
    [self addDevicesObject:device];
    
}

/**
 * Checks if the delegate of VSPlaybackControllerDelegate is able to respond to the given Selector
 * @param selector Selector the delegate will be checked for if it is able respond to
 * @return YES if the delegate is able to respond to the selector, NO otherweis
 */
-(BOOL) delegateRespondsToSelector:(SEL) selector{
    if(self.deviceRegisitratingDelegate){
        if([self.deviceRegisitratingDelegate conformsToProtocol:@protocol(VSDeviceParameterRegistrationDelegate)]){
            if([self.deviceRegisitratingDelegate respondsToSelector:selector]){
                return YES;
            }
        }
    }
    return NO;
}

- (NSArray *)availableInputs
{
    return [self.externalInputManager availableInputs];
}


@end
