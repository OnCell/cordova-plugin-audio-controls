#import <Cordova/CDVPlugin.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AudioControls : CDVPlugin {
  NSString *callbackId;
}

@property (nonatomic, copy) NSString *callbackId;

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)updateDisplay:(CDVInvokedUrlCommand *)command;

@end
