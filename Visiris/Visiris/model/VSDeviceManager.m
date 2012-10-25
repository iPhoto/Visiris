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
#import "VSExternalInput.h"
#import "VSExternalInputRepresentation.h"

#import "VSCoreServices.h"

#define ELEMENTNAMEDEVICE @"deciveName"
#define ELEMENTNAMEPARAMETER @"parameter"
#define ATTRIBUTENAME @"name"
#define ATTRIBUTEIDENTIFIER @"identifier"
#define ATTRIBUTEDATATYPE @"dataType"
#define ATTRIBUTEFROMVALUE @"fromValue"
#define ATTRIBUTETOVALUE @"toValue"
#define ATTRIBUTEDEVICEID @"deviceID"


@interface VSDeviceManager()


@end


@implementation VSDeviceManager

#define kDevices @"Devices"

static NSString *devicesFolder;

static NSURL* devicesFolderURL;

@synthesize devices             = _devices;
@synthesize availableInputsRepresentation     = _availableInputsRepresentation;

#pragma mark - Init

+(void) initialize{
    NSString *applicationSupportFolder = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *visirisFolderName = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*) kCFBundleNameKey];
    
    devicesFolder = [NSString stringWithFormat:@"%@/%@/devices",applicationSupportFolder,visirisFolderName];
    devicesFolderURL = [NSURL fileURLWithPath:devicesFolder];
    NSError *error;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:devicesFolder
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    
    if(error){
        DDLogInfo(@"%@",error);
    }
}

-(id) init{
    if(self = [super init]){
        self.deviceRepresentations = [[NSMutableArray alloc] init];
        self.devices = [[NSMutableArray alloc]init];
        _availableInputsRepresentation = [[NSMutableArray alloc] init];
        self.externalInputManager = [VSExternalInputManager sharedExternalInputManager];
        
        for(VSExternalInput *input in self.externalInputManager.availableInputs){
            [self addRepresentationOfExternalInput:input];
        }
        
        [self.externalInputManager addObserver:self forKeyPath:@"availableInputs"
                                       options:NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionNew
                                       context:nil];
        
        [self loadExisitingDevices];
    }
    
    return self;
}

-(id) initWithDevices:(NSArray*) devices{
    if(self = [super init]){
        self.deviceRepresentations = [NSMutableArray arrayWithArray:devices];
        self.devices = [[NSMutableArray alloc]init];
        _availableInputsRepresentation = [[NSMutableArray alloc] init];
        self.externalInputManager = [VSExternalInputManager sharedExternalInputManager];
        
        for(VSExternalInput *input in self.externalInputManager.availableInputs){
            [self addRepresentationOfExternalInput:input];
        }
        
        [self.externalInputManager addObserver:self forKeyPath:@"availableInputs"
                                       options:NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionNew
                                       context:nil];
        
       // [self loadExisitingDevices];
    }
    
    return self;
}

#pragma mark - NSObject

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"availableInputs"]){
        
        NSInteger kind = [[change valueForKey:@"kind"] intValue];
        
        switch (kind) {
            case NSKeyValueChangeInsertion:
            {
                if(![[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSArray *newAvailableInputs = [self.externalInputManager.availableInputs objectsAtIndexes:[change  objectForKey:@"indexes"]];
                    
                    for(VSExternalInput *newInput in newAvailableInputs){
                        [self addRepresentationOfExternalInput:newInput];
                    }
                }
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                //                if([[change valueForKey:@"notificationIsPrior"] boolValue]){
                //                    NSArray *removedInputs = [self.externalInputManager.availableInputs objectsAtIndexes:[change  objectForKey:@"indexes"]];
                //
                //                    for(VSExternalInput *removedInput in removedInputs){
                //                        [self removeRepresentaionOfExternalInput:removedInput];
                //                    }
                //
                //                }
                //                else{
                //
                //                }
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - NSCoding implementaion

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.devices forKey:kDevices];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    NSArray *devices = [aDecoder decodeObjectForKey:kDevices];
    
    if(self = [[VSDeviceManager alloc] initWithDevices:devices]){
        
    }
    
    return self;
}

#pragma mark - Methods


-(void) resetAvailableInputsRepresentation{
    for(VSExternalInputRepresentation *representation in self.availableInputsRepresentation){
        [representation reset];
    }
}

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

-(BOOL) createDeviceWithName:(NSString *)deviceName andParameters:(NSArray *)parameters{
    VSDevice *newDevice = [[VSDevice alloc] initWithID:[VSMiscUtlis stringWithUUID] andName:deviceName];
    
    //todo range abfragen
    for(VSExternalInputRepresentation *representation in parameters){
        
        VSDeviceParameter *deviceParameter = nil;
        if(representation.hasRange){
            deviceParameter = [[VSDeviceParameter alloc] initWithName:representation.name
                                                               ofType:representation.externalInput.deviceParameterDataType
                                                           identifier:representation.identifier
                                                            fromValue:representation.range.min
                                                              toValue:representation.range.max];
        }
        else{
            deviceParameter = [[VSDeviceParameter alloc] initWithName:representation.name
                                                               ofType:representation.externalInput.deviceParameterDataType
                                                           identifier:representation.identifier];
        }
        
        [newDevice addParametersObject:deviceParameter];
    }
    
    
    
    
    if( [self saveXMLOfDevice:newDevice]){
        [self addDevicesObject:newDevice];
        
        return YES;
    }
    
    return NO;
    
}

-(BOOL) saveXMLOfDevice:(VSDevice*) device{
    NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:ELEMENTNAMEDEVICE];
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    
    [root addAttribute:[NSXMLNode attributeWithName:ATTRIBUTENAME stringValue:device.name]];
    [root addAttribute:[NSXMLNode attributeWithName:ATTRIBUTEDEVICEID stringValue:device.ID]];
    
    for(VSDeviceParameter *parameter in [device.parameters allValues])
    {
        NSXMLElement *element = [NSXMLElement elementWithName:ELEMENTNAMEPARAMETER];
        [element addAttribute:[NSXMLNode attributeWithName:ATTRIBUTENAME stringValue:parameter.name]];
        [element addAttribute:[NSXMLNode attributeWithName:ATTRIBUTEIDENTIFIER stringValue:parameter.identifier]];
        [element addAttribute:[NSXMLNode attributeWithName:ATTRIBUTEDATATYPE stringValue:[VSDeviceParameterUtils stringForDeviceParameterDataType:parameter.dataType]]];
        
        if ([parameter hasRange])
        {
            [element addAttribute:[NSXMLNode attributeWithName:ATTRIBUTEFROMVALUE stringValue:[NSString stringWithFormat:@"%f",parameter.range.min]]];
            [element addAttribute:[NSXMLNode attributeWithName:ATTRIBUTETOVALUE stringValue:[NSString stringWithFormat:@"%f",parameter.range.max]]];
        }
        [root addChild:element];
    }
    
    
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    
    
    
    NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    
    NSString  *path = [NSString stringWithFormat:@"%@/%@_%@.xml",devicesFolder,device.name,device.ID];
    
    if (![xmlData writeToFile:path atomically:YES]) {
        return NO;
        DDLogError(@"Could not write document out...");
    }
    
    return YES;
}

#pragma mark - VSDeviceDelegate Implementation

-(BOOL) registerDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device{
    BOOL result = NO;
    
    if([self delegateRespondsToSelector:@selector(registerValue:forIdentifier:)]){
        result = [self.deviceRegisitratingDelegate registerValue:[deviceParameter invocationForNewValue]
                                                   forIdentifier:deviceParameter.identifier];
    }
    
    return result;
}

-(BOOL) unregisterDeviceParameter:(VSDeviceParameter *)deviceParameter ofDevice:(VSDevice *)device{
    BOOL result = NO;
    
    if([self delegateRespondsToSelector:@selector(unregisterValue:forIdentifier:)]){
        result = [self.deviceRegisitratingDelegate unregisterValue:[deviceParameter invocationForNewValue]
                                                     forIdentifier:deviceParameter.identifier];
    }
    
    return result;
}

-(VSDevice*) deviceIdentifiedByID:(NSString*) idString{
    NSUInteger indexOfDevice = [self.devices indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSDevice class]]){
            return [((VSDevice*) obj).ID isEqualToString:idString];
        }
        return NO;
    }];
    
    if(indexOfDevice != NSNotFound){
        return [self.devices objectAtIndex:indexOfDevice];
    }
    
    return nil;
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
    
    NSString *name = [[deviceNode attributeForName:ATTRIBUTENAME] stringValue];
    NSString *guiid = [[deviceNode attributeForName:ATTRIBUTEDEVICEID] stringValue];
    
    
    VSDevice *device = [[VSDevice alloc] initWithID:guiid andName:name];
    
    NSArray *parameterNodes = [deviceNode elementsForName:ELEMENTNAMEPARAMETER];
    
    for(NSXMLElement *parameterNode in parameterNodes){
        
        NSString *name= [[parameterNode attributeForName:ATTRIBUTENAME] stringValue];
        NSString *identifier= [[parameterNode attributeForName:ATTRIBUTEIDENTIFIER] stringValue];
        
        BOOL hasRange = NO;
        float fromValue, toValue = 0.0f;
        
        if([parameterNode attributeForName:ATTRIBUTEFROMVALUE] && [parameterNode attributeForName:ATTRIBUTETOVALUE]){
            fromValue = [[[parameterNode attributeForName:ATTRIBUTEFROMVALUE] stringValue] floatValue];
            toValue = [[[parameterNode attributeForName:ATTRIBUTETOVALUE] stringValue] floatValue];
            
            hasRange = YES;
        }
        
        NSString *dataTypeName = [[parameterNode attributeForName:ATTRIBUTEDATATYPE] stringValue];
        
        NSError *error;
        
        VSDeviceParameterDataype datatype = [VSDeviceParameterUtils deviceParameterDatatypeForString:dataTypeName andError:&error];
        
        
        if(!error){
            VSDeviceParameter *deviceParameter = nil;
            if(hasRange){
                deviceParameter = [[VSDeviceParameter alloc] initWithName:name
                                                                   ofType:datatype
                                                               identifier:identifier
                                                                fromValue:fromValue
                                                                  toValue:toValue];
            }
            else{
                deviceParameter  = [[VSDeviceParameter alloc] initWithName:name
                                                                    ofType:datatype
                                                                identifier:identifier];
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

-(void) addRepresentationOfExternalInput:(VSExternalInput*) externalInput{
    
    NSUInteger indexOfInputWithSameIdentifier = [self.availableInputsRepresentation indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSExternalInputRepresentation class]]){
            if([((VSExternalInputRepresentation *)obj).identifier isEqualToString:externalInput.identifier]){
                return YES;
            }
        }
        
        return NO;
    }];
    
    if(indexOfInputWithSameIdentifier == NSNotFound){
        
        VSExternalInputRepresentation *newRepresentation = [[VSExternalInputRepresentation alloc] initWithExternalInput:externalInput];
        
        [self.availableInputsRepresentation addObject:newRepresentation];
    }
}

-(void) removeRepresentaionOfExternalInput:(VSExternalInput*) externalInput{
    NSUInteger indexOfObjectToRemove = [_availableInputsRepresentation indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[VSExternalInputRepresentation class]]){
            if([((VSExternalInputRepresentation*)obj).externalInput isEqual:externalInput]){
                return YES;
            }
        }
        return NO;
    }];
    
    if(indexOfObjectToRemove != NSNotFound){
        [self.availableInputsRepresentation removeObjectAtIndex:indexOfObjectToRemove];
    }
}

#pragma mark - Properties

- (NSMutableArray *)availableInputsRepresentation{
    return [self mutableArrayValueForKey:@"availableInputsRepresentation"];
}

@end
