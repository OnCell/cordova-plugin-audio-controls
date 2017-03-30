var exec = require('cordova/exec');

var PLUGIN_NAME = 'AudioControls';

var AudioControls = {
    
    handlers: {},
    
    /**
     * Set display options for audio player:
     * pause
     * play
     * stop
     * togglePlayPause
     * enableLanguageOption
     * disableLanguageOption
     * nextTrack
     * previousTrack
     * seekForward
     * seekBackward
     */
    setOptions: function(optionsDict) {
        console.log("AudioControls.setOptions");
        for (var option in optionsDict) {
            var enabled = optionsDict[option];
            exec(null, null, PLUGIN_NAME, 'setOption', [option, enabled]);
        }
    },
    
    /**
     * Set display of track info:
     * albumTitle
     * trackCount
     * trackNumber
     * artist
     * composer
     * discCount
     * discNumber
     * genre
     * persistentID
     * playbackDuration
     * title
     * elapsedPlaybackTime
     * playbackRate
     * playbackQueueCount
     * chapterNumber
     * chapterCount
     */
    setNowPlaying: function(nowPlayingDict) {
        console.log("AudioControls.setNowPlaying");
        var args = [];
        if (nowPlayingDict) {
            args.push(JSON.stringify(nowPlayingDict));
        }
        exec(null, null, PLUGIN_NAME, 'setNowPlaying', args);
    },
    
    clearNowPlaying: function() {
        console.log("AudioControls.clearNowPlaying");
        exec(null, null, PLUGIN_NAME, 'clearNowPlaying', []);
    },
    
    /**
     * Set a handler to run when audio player an event is received:
     * pause
     * play
     * stop
     * togglePlayPause
     * nextTrack
     * previousTrack
     * seekForward
     * seekBackward
     * enableLanguageOption
     * disableLanguageOption
     */
    on: function (evt, handler) { // Consider allowing context to be passed here
        console.log("AudioControls.on");
        if (!AudioControls.handlers.hasOwnProperty(evt)) {
            AudioControls.handlers[evt] = [];
        }
		AudioControls.handlers[evt].push(handler);
	},
    
    // Remove a handler set with on()
    off: function (evt, handler) {
        console.log("AudioControls.off");
        if (AudioControls.handlers.hasOwnProperty(evt)) {
            if (handler) {
                AudioControls.handlers[evt].splice(AudioControls.handlers[evt].indexOf(handler));
            } else {
                AudioControls.handlers[evt] = [];
            }
        }
    },
    
    handleEvent: function(evt) {
        console.log("AudioControls.handleEvent: " + evt);
        if (AudioControls.handlers.hasOwnProperty(evt)) {
            for (var i = 0; i < AudioControls.handlers[evt].length; i++) {
                AudioControls.handlers[evt][i].call(undefined, []); // Consider the context
            }
        }
    },
    
    init: function() {
        console.log("AudioControls.init");
        exec(AudioControls.handleEvent, null, PLUGIN_NAME, 'init', []);
    },
};

document.addEventListener('deviceready', function () {
	AudioControls.init();
}, false);

module.exports = AudioControls;
