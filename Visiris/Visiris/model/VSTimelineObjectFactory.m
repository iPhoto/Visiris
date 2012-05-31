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

/** Stores the Class objects of all Classes the Factory can create instances of. The name of the class is used as key in the dictionary. */
@property (strong) NSMutableDictionary *timelineObjectSourceClasses;


@property (strong) NSMutableDictionary *sourceSupplierClasses;

@end

@implementation VSTimelineObjectFactory

@synthesize timelineObjectSourceClasses = _timelineObjectSourceClasses;
@synthesize sourceSupplierClasses = _sourceSupplierClasses;

/** Sigleton instance */
static VSTimelineObjectFactory* sharedInstance;

#pragma mark- Init
-(id) init{
    if(self = [super init]){
        self.timelineObjectSourceClasses = [NSMutableDictionary dictionaryWithCapacity:0];
        self.sourceSupplierClasses = [NSMutableDictionary dictionaryWithCapacity:0];
        
        /** Registers a timeLineObjectSourceClass for every classtring stored in all supportFiles VSSupportedFilesManager is responsible for */
        for(VSFileType *fileType in [[VSSupportedFilesManager supportedFiles] allValues]){
            [self registerNewClass:fileType.timelineObjectSourceClassString];
            [self registerNewSupplierClass:fileType.supplierClassString];
        }
    }
    
    return self;
}

#pragma mark- Functions

+(VSTimelineObjectFactory*)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[VSTimelineObjectFactory alloc] init];
        
    });
    
    return sharedInstance;
}

#pragma mark- Methods


-(VSTimelineObject*) createTimelineObjectForProjectItem:(VSProjectItem *)projectItem{
    
    VSTimelineObjectSource *objectSourceBase = [self.timelineObjectSourceClasses objectForKey:projectItem.fileType.timelineObjectSourceClassString];
    
    Class sourceSupplierClass = [self.sourceSupplierClasses objectForKey:projectItem.fileType.supplierClassString];
    
    if(!sourceSupplierClass)
        return nil;
    
    VSSourceSupplier *sourceSupplier = [[sourceSupplierClass alloc] init];
    
    if(objectSourceBase){
        VSTimelineObjectSource *sourceObject = [objectSourceBase copy];
        sourceObject.projectItem = projectItem;
        NSImage* icon = [VSFileImageCreator createIconForTimelineObject:projectItem.filePath];
        
        VSTimelineObject *newTimelineObject = [[VSTimelineObject alloc] initWithSourceObject:sourceObject icon:icon];
        
        sourceSupplier.timelineObject = newTimelineObject;
        
        newTimelineObject.supplier = sourceSupplier;
        
        return newTimelineObject;
    }
    else
        return nil;
}

#pragma mark- Private Methods

/**
 * Adds a new class object defined by the classString to the timelineObjectSourceClasses Dictionary. The name of the class is used as key in the dictionary
 * @param classString Name of the class to register.
 * @return YES if the class was registrated successfully, NO if the class string was empty, the given class string doesn't name a class subclassed of VSTimelineObjectSource
 */
-(BOOL) registerNewClass:(NSString*)classString{
    
    if(!classString)
        return NO;
    
    Class classToRegister = NSClassFromString(classString);
    
    /** If the class is not a subclass of VSTimelineObjectSource the class is not valid for the factory and NO is returned. */
    if(![classToRegister isSubclassOfClass:[VSTimelineObjectSource class]])
        return NO;
    
    VSTimelineObjectSource *tmpObject = [[classToRegister alloc] init];
    
    tmpObject.parameters =  [self createParametersDictionaryFromXMLFile:[classToRegister parameterDefinitionXMLFileName]];
    
    [self.timelineObjectSourceClasses setObject:tmpObject forKey:NSStringFromClass(classToRegister)];
    return YES;
}

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


@end
