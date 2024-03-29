//
//  VSTimelineObjectFactory.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSTimelineObjectFactory.h"

#import "VSProjectItem.h"
#import "VSTimelineObject.h"
#import "VSFileType.h"
#import "VSSupportedFilesManager.h"
#import "VSTimelineObjectSource.h"
#import "VSParameter.h"
#import "VSSourceSupplier.h"

#import "VSCoreServices.h"

@interface VSTimelineObjectFactory()

/** Stores the  objects of all VSTimelineObjectSource child-classes the Factory can create instances of. The name of the class is used as key in the dictionary. */
@property (strong) NSMutableDictionary *timelineObjectSourceClasses;

/** Stores the Class objects of all VSSourceSupplier child-classes the Factory can create instances of. The name of the class is used as key in the dictionary. */
@property (strong) NSMutableDictionary *sourceSupplierClasses;

/** last unique timelineObjectID */
@property NSUInteger lastAssignedTimelineObjectID;
@end

@implementation VSTimelineObjectFactory

@synthesize timelineObjectSourceClasses     = _timelineObjectSourceClasses;
@synthesize sourceSupplierClasses           = _sourceSupplierClasses;
@synthesize lastAssignedTimelineObjectID    = _lastAssignedTimelineObjectID;

/** Sigleton instance */
static VSTimelineObjectFactory* sharedInstance;

#pragma mark- Init
-(id) init{
    if(self = [super init]){
        self.timelineObjectSourceClasses = [NSMutableDictionary dictionaryWithCapacity:0];
        self.sourceSupplierClasses = [NSMutableDictionary dictionaryWithCapacity:0];
        
        // Registers a timeLineObjectSourceClass for every classtring stored in all supportFiles VSSupportedFilesManager is responsible for
        for(VSFileType *fileType in [[VSSupportedFilesManager supportedFiles] allValues]){
            [self registerNewClass:fileType.timelineObjectSourceClassString];
            [self registerNewSupplierClass:fileType.supplierClassString];
        }
    }
    
    return self;
}

#pragma mark- Functions

+(VSTimelineObjectFactory*)sharedFactory{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[VSTimelineObjectFactory alloc] init];
        
    });
    
    return sharedInstance;
}

#pragma mark- Methods


-(VSTimelineObject*) createTimelineObjectForProjectItem:(VSProjectItem *)projectItem{
    
    VSTimelineObjectSource *sourceBaseObject = [self.timelineObjectSourceClasses objectForKey:projectItem.fileType.timelineObjectSourceClassString];
    
    
    
    if(sourceBaseObject){
        VSTimelineObjectSource *sourceObject = [[NSClassFromString(projectItem.fileType.timelineObjectSourceClassString) alloc] initWithProjectItem:projectItem andParameters:sourceBaseObject.parameters];
        
        NSImage* icon = [VSFileImageCreator createIconForTimelineObject:projectItem.filePath];
        
        VSTimelineObject *newTimelineObject = [[VSTimelineObject alloc] initWithSourceObject:sourceObject icon:icon objectID:[self assignNewTimelineObjectID]];
        
        
        Class sourceSupplierClass = [self.sourceSupplierClasses objectForKey:projectItem.fileType.supplierClassString];
        
        if(!sourceSupplierClass)
            return nil;
        
        VSSourceSupplier *sourceSupplier = [[sourceSupplierClass alloc] initWithTimelineObject:newTimelineObject];
        
        newTimelineObject.supplier = sourceSupplier;

        return newTimelineObject;
    }
    else
        return nil;
}

-(VSTimelineObject*) createCopyOfTimelineObject:(VSTimelineObject *)objectToCopy atStartTime:(double)aStartTime withDuration:(double)aDuration{
    VSTimelineObject *copiedTimelineObject = [objectToCopy copy];
    copiedTimelineObject.duration = aDuration;
    copiedTimelineObject.startTime = aStartTime;
    copiedTimelineObject.timelineObjectID = [self assignNewTimelineObjectID];
    return copiedTimelineObject;
}

#pragma mark- Private Methods

/**
 * Adds a new object defined by the classString to the timelineObjectSourceClasses Dictionary. The name of the class is used as key in the dictionary
 * @param classString Name of the class to register.
 * @return YES if the class was registrated successfully, NO if the class string was empty, the given class string doesn't name a class subclassed of VSTimelineObjectSource
 */
-(BOOL) registerNewClass:(NSString*)classString{
    
    if(!classString)
        return NO;
    
    Class classToRegister = NSClassFromString(classString);
    
    // If the class is not a subclass of VSTimelineObjectSource the class is not valid for the factory and NO is returned.
    if(![classToRegister isSubclassOfClass:[VSTimelineObjectSource class]])
        return NO;
    
    VSTimelineObjectSource *tmpObject = [[classToRegister alloc] init];
    
    tmpObject.parameters =  [self createParametersDictionaryFromXMLFile:[classToRegister parameterDefinitionXMLFileName]];
    
    [self.timelineObjectSourceClasses setObject:tmpObject forKey:NSStringFromClass(classToRegister)];
    return YES;
}

/**
 * Adds a new class object defined by the classString to the sourceSupplierClasses Dictionary. The name of the class is used as key in the dictionary
 * @param supplierClassString Name of the class to register.
 * @return YES if the class was registrated successfully, NO if the class string was empty, the given class string doesn't name a class subclassed of VSSourceSupplier
 */
-(BOOL) registerNewSupplierClass:(NSString*) supplierClassString{
    if (!supplierClassString) {
        return NO;
    }
    
    Class classToRegister = NSClassFromString(supplierClassString);
    
    if(!classToRegister || ! [classToRegister isSubclassOfClass:[VSSourceSupplier class]]) {
        return NO;
    }
    
    [self.sourceSupplierClasses setObject:classToRegister forKey:supplierClassString];
    return YES;
    
}

/**
 * Creates a NSDictionary of VSParameters according to the parameter information stored in the given xml-file
 * @param aXMLFile XML-File storing the parameter information
 * @return NSDictionary of VSParameters as stored inaXMLFile.
 */
-(NSDictionary *) createParametersDictionaryFromXMLFile:(NSString*)aXMLFile{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSString *path = [ [ NSBundle mainBundle ] pathForResource: aXMLFile ofType: @"xml" ];
    NSURL *xmlURL = [NSURL fileURLWithPath:path];
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithContentsOfURL:xmlURL options:0 error:nil];
    
    NSXMLElement *root = [doc rootElement];
    NSArray *parameterXMLElements = [root elementsForName:@"parameter"];
    
    int i = 0;
    
    for(NSXMLElement *element in parameterXMLElements){
        VSParameter *newParameter = [VSParameterXMLUtils parameterOfXMLNode:element atPosition:i++];
        
        [parameters setObject:newParameter forKey:newParameter.type];
    }
    
    return parameters;
}

/**
 * Increments lastAssignedTimelineObjectID and returns it
 * @return New unique TimelineObjectID
 */
-(NSInteger) assignNewTimelineObjectID{
    return ++self.lastAssignedTimelineObjectID;
}


@end
