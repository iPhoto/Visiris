//
//  VSExternalInputProtocol.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 9/26/12.
//
//

#import <Foundation/Foundation.h>


@protocol VSExternalInputProtocol <NSObject>

@required

- (void)startObservingInputs;
- (void)stopObservingInputs;

- (NSArray *)availableInputs;

@end
