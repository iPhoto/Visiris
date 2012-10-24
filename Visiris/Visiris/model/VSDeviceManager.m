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

@interface VSDeviceManager()

@property VSDeviceLoader *deviceLoader;


@end


@implementation VSDeviceManager

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
    
    for(VSExternalInputRepresentation *representation in parameters){
        VSDeviceParameter *deviceParameter = [[VSDeviceParameter alloc] initWithName:representation.name
                                                                              ofType:representation.externalInput.deviceParameterDataType
                                                                          identifier:representation.identifier
                                                                           fromValue:representation.range.min
                                                                             toValue:representation.range.max];
        
        [newDevice addParametersObject:deviceParameter];
    }
    
    [self addDevicesObject:newDevice];
    
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
        NSString *identifier= [[parameterNode attributeForName:@"identifier"] stringValue];
        
        BOOL hasRange = NO;
        float fromValue, toValue = 0.0f;
        
        if([parameterNode attributeForName:@"fromValue"] && [parameterNode attributeForName:@"toValue"]){
            fromValue = [[[parameterNode attributeForName:@"fromValue"] stringValue] floatValue];
            toValue = [[[parameterNode attributeForName:@"toValue"] stringValue] floatValue];
            
            hasRange = YES;
        }
        
        NSString *dataTypeName = [[parameterNode attributeForName:@"dataType"] stringValue];
        
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
