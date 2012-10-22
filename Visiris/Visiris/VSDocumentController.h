//
//  VSDocumentController.h
//  Visiris
//
//  Created by Martin Tiefengrabner on 01.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSDocument;

@interface VSDocumentController : NSDocumentController<NSApplicationDelegate>

+(id) documentOfView:(NSView*) view;

@end
