//
//  VSTimelineObjectDevicesViewController.m
//  Visiris
//
//  Created by Martin Tiefengrabner on 07.11.12.
//
//

#import "VSTimelineObjectDevicesViewController.h"
#import "VSDevice.h"
#import "VSTestView.h"
#import "VSCoreServices.h"
#import "VSTimelineObject.h"

@interface VSTimelineObjectDevicesViewController (){
    float _deviceViewHeight;
}

@property (strong) VSTimelineObject *timelineObject;

@end

@implementation VSTimelineObjectDevicesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


/** Name of the nib that will be loaded when initWithDefaultNib is called */
static NSString* defaultNib = @"VSTimelineObjectDevicesView";


#pragma mark - Init

-(id) initWithDefaultNibAndDeviceViewHeight:(float)deviceViewHeight{
    if(self = [self initWithNibName:defaultNib bundle:nil]){
        _deviceViewHeight = deviceViewHeight;
        [self.view setFrameOrigin:NSZeroPoint];
    }
    
    return self;
}

-(void) awakeFromNib{
    
}

#pragma mark -
#pragma mark NSViewController

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"devices"]){
        NSInteger kind = [[change valueForKey:@"kind"] intValue];
        
        switch (kind) {
            case NSKeyValueChangeInsertion:
            {
                if(![[change valueForKey:@"notificationIsPrior"] boolValue]){
                    NSArray *newDevices = [[object valueForKey:keyPath] objectsAtIndexes:[change  objectForKey:@"indexes"]];
                    
                    [self showDevices:newDevices];
                }
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                if(![[change valueForKey:@"notificationIsPrior"] boolValue]){
                    [self removeAllSubViews];
                    [self showDevices:self.timelineObject.devices];
                    
                }
                else{
                    
                }
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark IBAction

- (IBAction)didPressRemoveDeviceButton:(NSButton *)sender{
    VSDevice *deviceToRemove = [self.timelineObject deviceIdentifiedBy:sender.identifier];
    
    if(deviceToRemove){
        [self.timelineObject removeDevice:deviceToRemove];
    }
}

- (IBAction)didPressDisconnectDeviceButton:(NSButton *)sender{
    VSDevice *deviceToDisconnect = [self.timelineObject deviceIdentifiedBy:sender.identifier];
    
    if(deviceToDisconnect){
        [self.timelineObject disconnectDevice:deviceToDisconnect];
    }
}

#pragma mark -
#pragma mark Methods
-(void) showDevicesOfTimelineObject:(VSTimelineObject*)timelineObject{
    self.timelineObject = timelineObject;
    
    [self.timelineObject addObserver:self
                      forKeyPath:@"devices"
                         options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior
                         context:nil];
    
    [self showDevices:self.timelineObject.devices];
}

-(void) showDevices:(NSArray*) devices{
    for(VSDevice *device in devices){
        [self showDevice:device];
    }
    
    NSRect newFrame = self.view.frame;
    newFrame.origin = NSZeroPoint;
    newFrame.size = NSMakeSize(self.view.frame.size.width, self.view.subviews.count*_deviceViewHeight);
     
    [self.view setFrame:newFrame];
}

-(void) reset{
    [self removeAllSubViews];
    [self.timelineObject removeObserver:self
                             forKeyPath:@"devices"];
}

-(void) removeAllSubViews{
    for(NSInteger i = self.view.subviews.count-1; i >= 0; i--){
        [((NSView*)[self.view.subviews objectAtIndex:i]) removeFromSuperview];
    }
}

#pragma mark -
#pragma mark Private Methods

-(void) showDevice:(VSDevice*) device{
    NSRect holderRect = NSMakeRect(0, self.view.subviews.count*_deviceViewHeight, self.view.frame.size.width, _deviceViewHeight);
    
    NSView *deviceHolder = [[NSView alloc] initWithFrame:holderRect];
    [self.view addSubview:deviceHolder];
    
    [deviceHolder setAutoresizingMask:NSViewWidthSizable];
    [deviceHolder setAutoresizesSubviews:YES];
    
    
    NSTextField *deviceName = [[NSTextField alloc] init];
    [deviceHolder addSubview:deviceName];
    [deviceName setAutoresizingMask:NSViewWidthSizable];
    [deviceName setTranslatesAutoresizingMaskIntoConstraints:NO];
    [deviceName setFrameSize:deviceName.intrinsicContentSize];
    [deviceName setStringValue:device.name];
    [deviceName setEditable:NO];
    
    NSButton *disconnectButton = [[NSButton alloc] init];
    [disconnectButton setTitle:@"D"];
    [disconnectButton setIdentifier:device.ID];
    [deviceHolder addSubview:disconnectButton];
    [disconnectButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [disconnectButton setFrameSize:[disconnectButton intrinsicContentSize]];
    [disconnectButton setTarget:self];
    [disconnectButton setAction:@selector(didPressDisconnectDeviceButton:)];
    
    NSButton *removeButton = [[NSButton alloc] init];
    
    [removeButton setTitle:@"R"];
    [deviceHolder addSubview:removeButton];
    
    [removeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [removeButton setFrameSize:[removeButton intrinsicContentSize]];
    [removeButton setIdentifier:device.ID];
    [removeButton setTarget:self];
    [removeButton setAction:@selector(didPressRemoveDeviceButton:)];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(deviceName, removeButton, disconnectButton);
    NSString *constraintFormat = @"|-[deviceName]-[removeButton(20)]-[disconnectButton(20)]-|";
    
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintFormat
                                                                   options:0
                                                                   metrics:nil
                                                                     views:viewsDictionary];
    
    
    [deviceHolder addConstraints:constraints];
}

@end
