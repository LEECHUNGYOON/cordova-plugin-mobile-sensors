#import <Cordova/CDV.h>
#import <SensingKit/SensingKit.h>

@interface Mobsense : CDVPlugin

@property (nonatomic, strong) SensingKitLib *sensingKit;
@property CDVInvokedUrlCommand* commandglo;
- (void) start:(CDVInvokedUrlCommand*)command;
- (void) stop:(CDVInvokedUrlCommand*)command;
- (void) list:(CDVInvokedUrlCommand*)command;
- (void) getState:(CDVInvokedUrlCommand*)command;
- (SKSensorType)getSensorEnum:(NSString*)sensorString :(CDVInvokedUrlCommand*)command;
- (NSArray*) getSensorArray;


@end

