//
//  VSInput.h
//  Visiris
//
//  Created by Edwin Guggenbichler on 10/16/12.
//
//

#import <Foundation/Foundation.h>
#import "VSCoreServices.h"
#import "VSDeviceParameter.h"
#import "VSDeviceType.h"

@interface VSExternalInput : NSObject

@property (readonly, strong) NSString       *identifier;
@property (assign) id                       value;
@property (assign) VSRange                  range;
@property (readonly, strong) NSString       *parameterTypeName;
@property (assign) VSDeviceType             deviceType;
@property (strong, readonly) NSString       *deviceTypeName;
@property VSDeviceParameterDataype          deviceParameterDataType;
@end
