//
//  VSImageSourceSupplier.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSFrameSourceSupplier.h"
@class VSImage;

/**
 * Supplier for VSTimelineObjects with VSVImageSource
 */
@interface VSImageSourceSupplier : VSFrameSourceSupplier
//@property (strong) NSImage *image;
@property (strong) VSImage *vsImage;
@end
