#import "AudioControls.h"

#import <Cordova/CDVAvailability.h>

@implementation AudioControls

@synthesize callbackId;

- (void)pluginInitialize {
  NSLog(@"AudioControls.pluginInitialize");
  MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
  
  [commandCenter.pauseCommand addTarget:self action:@selector(onPause:)];
  [commandCenter.playCommand addTarget:self action:@selector(onPlay:)];
  [commandCenter.stopCommand addTarget:self action:@selector(onStop:)];
  [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(onTogglePlayPause:)];
  [commandCenter.enableLanguageOptionCommand addTarget:self action:@selector(onEnableLanguageOption:)];
  [commandCenter.disableLanguageOptionCommand addTarget:self action:@selector(onDisableLanguageOption:)];
  [commandCenter.nextTrackCommand addTarget:self action:@selector(onNextTrack:)];
  [commandCenter.previousTrackCommand addTarget:self action:@selector(onPreviousTrack:)];
  [commandCenter.seekForwardCommand addTarget:self action:@selector(onSeekForward:)];
  [commandCenter.seekBackwardCommand addTarget:self action:@selector(onSeekBackward:)];
}

- (void)init:(CDVInvokedUrlCommand*)command {
  self.callbackId = command.callbackId;
  NSLog(@"AudioControls.init with callbackId: %@", self.callbackId);
}

- (void)onPause:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"pause"]; }
- (void)onPlay:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"play"]; }
- (void)onStop:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"stop"]; }
- (void)onTogglePlayPause:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"togglePlayPause"]; }
- (void)onEnableLanguageOption:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"enableLanguageOption"]; }
- (void)onDisableLanguageOption:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"disableLanguageOption"]; }
- (void)onNextTrack:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"nextTrack"]; }
- (void)onPreviousTrack:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"previousTrack"]; }
- (void)onSeekForward:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"seekForward"]; }
- (void)onSeekBackward:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"seekBackward"]; }

- (void)sendEvent:(NSString*)event {
	NSLog(@"AudioControls.sendEvent: %@", event);
	if (self.callbackId != nil) {
		CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:event];
		[pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
	}
}

- (void)setOption:(CDVInvokedUrlCommand *)command {
  MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
  NSString *option = [command.arguments objectAtIndex:0];
	bool enabled = [[command.arguments objectAtIndex:1] boolValue];
  NSLog(@"setOption: %@ - %d", option, enabled);
  
  if ([option isEqual: @"pause"]) {
		commandCenter.pauseCommand.enabled = enabled;
	} else if ([option isEqual: @"play"]) {
		commandCenter.playCommand.enabled = enabled;
	} else if ([option isEqual: @"stop"]) {
		commandCenter.stopCommand.enabled = enabled;
	} else if ([option isEqual: @"togglePlayPause"]) {
		commandCenter.togglePlayPauseCommand.enabled = enabled;
	} else if ([option isEqual: @"enableLanguageOption"]) {
		commandCenter.enableLanguageOptionCommand.enabled = enabled;
	} else if ([option isEqual: @"disableLanguageOption"]) {
		commandCenter.disableLanguageOptionCommand.enabled = enabled;
	} else if ([option isEqual: @"nextTrack"]) {
		commandCenter.nextTrackCommand.enabled = enabled;
	} else if ([option isEqual: @"previousTrack"]) {
		commandCenter.previousTrackCommand.enabled = enabled;
	} else if ([option isEqual: @"seekForward"]) {
		commandCenter.seekForwardCommand.enabled = enabled;
	} else if ([option isEqual: @"seekBackward"]) {
		commandCenter.seekBackwardCommand.enabled = enabled;
	}
}

- (void)setNowPlaying:(CDVInvokedUrlCommand *)command {
  MPNowPlayingInfoCenter *nowPlayingCenter = [MPNowPlayingInfoCenter defaultCenter];
  NSLog(@"AudioControls.setNowPlaying");
  
  if ([command.arguments count] == 0) {
      nowPlayingCenter.nowPlayingInfo = nil;
      return;
  }

  NSString *jsonStr = [command.arguments objectAtIndex:0];
  NSDictionary *nowPlayingDict;
  NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
  nowPlayingDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];

  if (nowPlayingDict == nil) {
      return;
  }
  
  NSLog( @"nowPlayingDict: %@", nowPlayingDict );
  
  NSMutableDictionary *nowPlayingInfo = (nowPlayingCenter.nowPlayingInfo != nil) ? [[NSMutableDictionary alloc] initWithDictionary: nowPlayingCenter.nowPlayingInfo] : [NSMutableDictionary dictionary];

  if ([nowPlayingDict objectForKey: @"albumTitle"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"albumTitle"] forKey:MPMediaItemPropertyAlbumTitle];
  }
  if ([nowPlayingDict objectForKey: @"trackCount"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"trackCount"] forKey:MPMediaItemPropertyAlbumTrackCount];
  }
  if ([nowPlayingDict objectForKey: @"trackNumber"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"trackNumber"] forKey:MPMediaItemPropertyAlbumTrackNumber];
  }
  if ([nowPlayingDict objectForKey: @"artist"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"artist"] forKey:MPMediaItemPropertyArtist];
  }
  if ([nowPlayingDict objectForKey: @"composer"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"composer"] forKey:MPMediaItemPropertyComposer];
  }
  if ([nowPlayingDict objectForKey: @"discCount"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"discCount"] forKey:MPMediaItemPropertyDiscCount];
  }
  if ([nowPlayingDict objectForKey: @"discNumber"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"discNumber"] forKey:MPMediaItemPropertyDiscNumber];
  }
  if ([nowPlayingDict objectForKey: @"genre"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"genre"] forKey:MPMediaItemPropertyGenre];
  }
  if ([nowPlayingDict objectForKey: @"persistentID"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"persistentID"] forKey:MPMediaItemPropertyPersistentID];
  }
  if ([nowPlayingDict objectForKey: @"playbackDuration"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"playbackDuration"] forKey:MPMediaItemPropertyPlaybackDuration];
  }
  if ([nowPlayingDict objectForKey: @"title"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"title"] forKey:MPMediaItemPropertyTitle];
  }
  if ([nowPlayingDict objectForKey: @"elapsedPlaybackTime"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"elapsedPlaybackTime"] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
  }
  if ([nowPlayingDict objectForKey: @"playbackRate"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"playbackRate"] forKey:MPNowPlayingInfoPropertyPlaybackRate];
  } else {
      [nowPlayingInfo setValue:[NSNumber numberWithDouble:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
  }
  if ([nowPlayingDict objectForKey: @"playbackQueueIndex"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"playbackQueueIndex"] forKey:MPNowPlayingInfoPropertyPlaybackQueueIndex];
  }
  if ([nowPlayingDict objectForKey: @"playbackQueueCount"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"playbackQueueCount"] forKey:MPNowPlayingInfoPropertyPlaybackQueueCount];
  }
  if ([nowPlayingDict objectForKey: @"chapterNumber"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"chapterNumber"] forKey:MPNowPlayingInfoPropertyChapterNumber];
  }
  if ([nowPlayingDict objectForKey: @"chapterCount"] != nil) {
      [nowPlayingInfo setValue:[nowPlayingDict objectForKey: @"chapterCount"] forKey:MPNowPlayingInfoPropertyChapterCount];
  }

  nowPlayingCenter.nowPlayingInfo = nowPlayingInfo;
}

- (void)clearNowPlaying:(CDVInvokedUrlCommand *)command {
  MPNowPlayingInfoCenter *nowPlayingCenter = [MPNowPlayingInfoCenter defaultCenter];
  NSLog(@"AudioControls.clearNowPlaying");
  nowPlayingCenter.nowPlayingInfo = nil;
}

@end
