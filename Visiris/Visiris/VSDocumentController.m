//
//  VSDocumentController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 01.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSDocumentController.h"

#import "VSDocument.h"

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

-(void) openDocumentWithContentsOfURL:(NSURL *)url display:(BOOL)displayDocument completionHandler:(void (^)(NSDocument *, BOOL, NSError *))completionHandler{
    NSString *fileName = [url path];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName]){
        NSString *type =[[NSWorkspace sharedWorkspace] typeOfFile:fileName error:nil];
        DDLogError(@"Check if the file is an visirs file");
        if([type isEqualToString:@"visirs"]){
            [super openDocumentWithContentsOfURL:url display:displayDocument completionHandler:completionHandler];
        }
        else {
            if([self.currentDocument isKindOfClass:[VSDocument class]]){
                [((VSDocument*) self.currentDocument) addFileToProject:fileName];
            }
        }
    }
}

-(BOOL) application:(NSApplication *)sender openFile:(NSString *)filename{
    if([[NSFileManager defaultManager] fileExistsAtPath:filename]){

        DDLogError(@"Check if the file is an visirs file");
        if([self.currentDocument isKindOfClass:[VSDocument class]]){
            return [((VSDocument*) self.currentDocument) addFileToProject:filename];
        }
    }
    
    return NO;
}


@end
