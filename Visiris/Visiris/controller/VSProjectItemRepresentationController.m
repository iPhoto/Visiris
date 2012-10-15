//
//  VSProjectItemRepresentationController.m
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSProjectItemRepresentationController.h"
#import "VSProjectItemRepresentation.h"
#import "VSProjectItemController.h"

#import "VSCoreServices.h"

@interface VSProjectItemRepresentationController()

@property VSProjectItemController *projectItemController;

@property NSMutableDictionary *temporaryCreatedProjectItems;

@end

@implementation VSProjectItemRepresentationController

@synthesize projectItemRepresentations =_projectItemRepresentations;
@synthesize projectItemController = _projectItemController;

static VSProjectItemRepresentationController* sharedProjectItemController = nil;

#pragma mark- Init

-(id) init{
    if(self = [super init]){
        self.projectItemController = [VSProjectItemController sharedManager];
        _projectItemRepresentations = [NSMutableArray arrayWithCapacity:0];
        self.temporaryCreatedProjectItems = [[NSMutableDictionary alloc] init];
        
        [self initObservers];
        
        [self initProjectItemRepresentations];
    }
    
    return self;
}

-(void) initObservers{
    [self.projectItemController addObserver:self
                                 forKeyPath:@"projectItems"
                                    options:0
                                    context:nil];
}


#pragma mark - NSObject Methods

//TODO: Remove Presentation if ProjectItem was removed
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    // observes the array of VSProjectItems of the VSProjecItemControllre for changes
    if([keyPath isEqualToString:@"projectItems"]){
        id item = [change objectForKey:@"indexes"];
        
        //if a new ProjectItem was added, a representation as created for it
        if([item isKindOfClass:[NSIndexSet class]]){
            NSInteger index = [((NSIndexSet*) item) firstIndex];
            [self addNewRepresentationOfProjectItem:[[object valueForKey:keyPath] objectAtIndex:index]];
        }
    }
}



#pragma mark- Functions

+(VSProjectItemRepresentationController*)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedProjectItemController = [[VSProjectItemRepresentationController alloc] init];
        
    });
    
    return sharedProjectItemController;
}




#pragma mark - Methods

-(VSProjectItemRepresentation*) createPresentationOfProjectItem:(VSProjectItem*) projectItem{
    
    if(!projectItem){
        return nil;
    }
    
    NSImage *icon = [VSFileImageCreator createIconForProjectItem:projectItem.filePath];
    
    return [[VSProjectItemRepresentation alloc] initWithFile:projectItem.filePath
                                                      ofType:projectItem.fileType
                                                        name:projectItem.name
                                                    fileSize:projectItem.fileSize
                                                    duration:projectItem.duration
                                                      itemID:projectItem.itemID
                                                    fileIcon:icon];
}

-(BOOL) addNewRepresentationOfProjectItem:(VSProjectItem*) projectItem{
    VSProjectItemRepresentation* newRepresentation = [self createPresentationOfProjectItem:projectItem];
    
    if(newRepresentation){
        [self.projectItemRepresentations addObject:newRepresentation];
        return YES;
    }
    else {
        return NO;
    }
}

-(NSArray*) representationsForFiles:(NSArray*) filePaths{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *currentTemporaryProjectItems = [NSMutableDictionary dictionaryWithDictionary:self.temporaryCreatedProjectItems];
    
    [self.temporaryCreatedProjectItems removeAllObjects];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    for(NSString *fileName in filePaths){
        

            VSProjectItemRepresentation *tmpProjectItemRepresentation = [currentTemporaryProjectItems objectForKey:fileName];
            
            if(!tmpProjectItemRepresentation){
                
                VSProjectItem *tempProjectItem = [self.projectItemController createNewProjectItemFromFile:fileName];
                
                if(tempProjectItem){
                    tmpProjectItemRepresentation = [self createPresentationOfProjectItem:tempProjectItem];
                }
            }
            
            if(tmpProjectItemRepresentation){
                [result addObject:tmpProjectItemRepresentation];
                [self.temporaryCreatedProjectItems setObject:tmpProjectItemRepresentation forKey:fileName];
            }
            

        
    }
    
    return result;
}


#pragma mark- Private Methods

/**
 * Creates a VSProjectItemRepresentation for VSProjectItem stored in the VSProjectItemController
 */
-(void) initProjectItemRepresentations{
    for(VSProjectItem *item in self.projectItemController.projectItems){
        [self addNewRepresentationOfProjectItem:item];
    }
}

#pragma mark- Properties

-(NSMutableArray*) projectItemRepresentations{
    return [self mutableArrayValueForKey:@"projectItemRepresentations"];
}

@end
