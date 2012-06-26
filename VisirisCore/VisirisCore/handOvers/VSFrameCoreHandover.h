//
//  VSFrameCoreHandover.h
//  VisirisUI
//
//  Created by Martin Tiefengrabner on 16.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VSCoreHandover.h"

@class VSImage;
/**
 * The VSCoreHandover is used to handover data from the UI/Model-Part of Visiris to the RenderCore. Besides the data the parent class VSCoreHandover provides, VSFrameCoreHandover stores a pointer to the frame of connected TimelineObject at a specifice timestamp.
 */
@interface VSFrameCoreHandover : VSCoreHandover

@property (strong) VSImage* frame;

@property GLuint textureID;
 
/**
 * Inits the VSCoreHandover for the given timestmap with the given attributes
 * @param inFrame contains the Data of the Image
 * @param theAttributes NSDictionary containing the parameters, the VSParemterType property of the VSParameter object is used as Key.
 * @param aTextureID The Of the Texture in the OpenGL Context
 * @param theTimestamp The timestamp the data is set of
 * @param theId ID of the Timelineobject
 * @return self
 */
-(id) initWithFrame:(VSImage*)inFrame andAttributes:(NSDictionary *) theAttributes forTextureID:(GLuint) aTextureID forTimestamp:(double)theTimestamp forId:(NSInteger) theId;

@end
