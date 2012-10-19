//
//  VSDocumentController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 01.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDocumentController.h"

#import "VSDocument.h"
#import "VSMainWindowController.h"

#import "VSCoreServices.h"

@implementation VSDocumentController


-(void) awakeFromNib{
    
}

-(void) applicationDidFinishLaunching:(NSNotification *)notification{
    VSLogFormatter *logFormatter = [[VSLogFormatter alloc] init];
    [[DDTTYLogger sharedInstance] setLogFormatter:logFormatter];
    [[DDASLLogger sharedInstance] setLogFormatter:logFormatter];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
}

+(id) documentOfView:(NSView*) view{
    if([view.window.delegate isKindOfClass:[VSMainWindowController class]]){
        id document = ((VSMainWindowController*) view.window.delegate).document;
        
        if([document isKindOfClass:[VSDocument class]]){
            return document;
        }
    }
    
    return nil;
}


@end
