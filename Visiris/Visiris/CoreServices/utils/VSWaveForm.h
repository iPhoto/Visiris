//
//  VSWaveForm.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/10/12.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAsset.h>

@interface VSWaveForm : NSObject

+ (NSImage *) renderPNGAudioPictogramForAssett:(AVURLAsset *)songAsset;

@end
