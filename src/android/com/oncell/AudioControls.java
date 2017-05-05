package com.oncell;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;
import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.content.Context;
import android.content.IntentFilter;
import android.content.Intent;
import android.app.PendingIntent;
import android.content.ServiceConnection;
import android.content.ComponentName;
import android.app.Service;
import android.os.IBinder;
import android.os.Bundle;
import android.os.Build;
import android.graphics.BitmapFactory;
import android.graphics.Bitmap;
import android.R;
import android.content.BroadcastReceiver;
import android.media.AudioManager;
import android.view.KeyEvent;

public class AudioControls extends CordovaPlugin {
  private static final String TAG = "AudioControls";
  
  private class AudioControlsBroadcastReceiver extends BroadcastReceiver {
    private CallbackContext cb;
    
    public AudioControlsBroadcastReceiver(AudioControls audioControls) {}
    
    public void setCallback(CallbackContext cb) {
      this.cb = cb;
    }
    
    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      PluginResult result;
      switch (action) {
        case "play":
          result = new PluginResult(PluginResult.Status.OK, "play");
          result.setKeepCallback(true);
          this.cb.sendPluginResult(result);
          break;
        case "pause":
          result = new PluginResult(PluginResult.Status.OK, "pause");
          result.setKeepCallback(true);
          this.cb.sendPluginResult(result);
					break;
        case "destroy":
          result = new PluginResult(PluginResult.Status.OK, "destroy");
          result.setKeepCallback(true);
          this.cb.sendPluginResult(result);
					break;
        default:
          result = new PluginResult(PluginResult.Status.OK, action);
          result.setKeepCallback(true);
          this.cb.sendPluginResult(result);
					break;
      }
    }
  }
  
  public class AudioControlsNotification {
    private Activity activity;
    private NotificationManager notificationManager;
    public JSONObject nowPlaying;
    
    public AudioControlsNotification(Activity activity) {
        this.activity = activity;
        Context context = activity;
        this.notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
    }
    
    public void setNowPlaying(JSONArray args) {
      try {
        if (this.nowPlaying == null) {
          this.nowPlaying = new JSONObject(args.getString(0));
        } else {
          JSONObject newNowPlaying = new JSONObject(args.getString(0));
          for(int i = 0; i<newNowPlaying.names().length(); i++) {
            String key = newNowPlaying.names().getString(i);
            this.nowPlaying.put(key, newNowPlaying.get(key));
          }
        }
        Log.d(TAG, this.nowPlaying.toString(2));
      	Notification notification = this.buildNotification();
      	this.notificationManager.notify(1160, notification);
      } catch (JSONException ex) {
        Log.d(TAG, ex.getMessage());
      }
    }
    
    public void clearNowPlaying() {
		  this.notificationManager.cancel(1160);
      this.nowPlaying = null;
    }
    
    public Notification buildNotification() throws JSONException {
      Context context = activity;
      Notification.Builder builder = new Notification.Builder(context);
      
      // Set notification details
      builder.setContentTitle(this.nowPlaying.getString("title"));
      builder.setContentText(this.nowPlaying.getString("artist"));
      builder.setSmallIcon(R.drawable.ic_media_play);
      Bitmap largeIcon = BitmapFactory.decodeResource(context.getResources(), context.getResources().getIdentifier("icon", "drawable", context.getPackageName()));
      builder.setLargeIcon(largeIcon);
      builder.setWhen(0);
      
      // Set whether the notification is dismissable
      // builder.setOngoing(true); // If the notification should NOT be dismissable
      builder.setOngoing(false);
			Intent dismissIntent = new Intent("destroy");
			PendingIntent dismissPendingIntent = PendingIntent.getBroadcast(context, 1, dismissIntent, 0);
			builder.setDeleteIntent(dismissPendingIntent);
      
      // Set notification priority
      builder.setPriority(Notification.PRIORITY_MAX);
      if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
			     builder.setVisibility(Notification.VISIBILITY_PUBLIC);
		  }
      
      // Open app if notification is clicked (not enabled now since we send another clickable alert)
  		// Intent resultIntent = new Intent(context, activity.getClass());
  		// resultIntent.setAction(Intent.ACTION_MAIN);
  		// resultIntent.addCategory(Intent.CATEGORY_LAUNCHER);
  		// PendingIntent resultPendingIntent = PendingIntent.getActivity(context, 0, resultIntent, 0);
  		// builder.setContentIntent(resultPendingIntent);
      
      // Controls
      boolean isPlaying = this.nowPlaying.getBoolean("isPlaying");
      if (isPlaying) {
        Intent pauseIntent = new Intent("pause");
  			PendingIntent pausePendingIntent = PendingIntent.getBroadcast(context, 1, pauseIntent, 0);
  			builder.addAction(android.R.drawable.ic_media_pause, "", pausePendingIntent);
      } else {
        Intent playIntent = new Intent("play");
  			PendingIntent playPendingIntent = PendingIntent.getBroadcast(context, 1, playIntent, 0);
  			builder.addAction(android.R.drawable.ic_media_play, "", playPendingIntent);
      }
      
  		if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
  			builder.setStyle(new Notification.MediaStyle().setShowActionsInCompactView(0));
  		}
      
      return builder.build();
    }
  }
  
  private AudioControlsBroadcastReceiver audioControlsBroadcastReceiver;
  public AudioControlsNotification audioControlsNotification;
  private AudioManager audioManager;
  private PendingIntent mediaButtonPendingIntent;

  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
    Log.d(TAG, "Initializing AudioControls");
    
    final Activity activity = this.cordova.getActivity();
		final Context context = activity.getApplicationContext();
    
    this.audioControlsNotification = new AudioControlsNotification(activity);
    this.audioControlsNotification.clearNowPlaying();
    this.audioControlsBroadcastReceiver = new AudioControlsBroadcastReceiver(this);
    
		context.registerReceiver((BroadcastReceiver)audioControlsBroadcastReceiver, new IntentFilter("pause"));
		context.registerReceiver((BroadcastReceiver)audioControlsBroadcastReceiver, new IntentFilter("play"));
    context.registerReceiver((BroadcastReceiver)audioControlsBroadcastReceiver, new IntentFilter("destroy"));
		context.registerReceiver((BroadcastReceiver)audioControlsBroadcastReceiver, new IntentFilter("audio-controls-media-button"));
    
    this.audioManager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
    Intent mediaButtonIntent = new Intent("audio-controls-media-button");
    this.mediaButtonPendingIntent = PendingIntent.getBroadcast(context, 0, mediaButtonIntent, PendingIntent.FLAG_UPDATE_CURRENT);
    this.audioManager.registerMediaButtonEventReceiver(this.mediaButtonPendingIntent);
    
  }

  public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    if (action.equals("init")) {
      Log.d(TAG, "init");
      this.cordova.getThreadPool().execute(new Runnable() {
				public void run() {
					audioControlsBroadcastReceiver.setCallback(callbackContext);
				}
			});
		} else if (action.equals("setNowPlaying")) {
      Log.d(TAG, "setNowPlaying");
      this.cordova.getThreadPool().execute(new Runnable() {
				public void run() {
					audioControlsNotification.setNowPlaying(args);
					callbackContext.success("success");
				}
			});
    } else if (action.equals("clearNowPlaying")) {
      Log.d(TAG, "clearNowPlaying");
      this.cordova.getThreadPool().execute(new Runnable() {
				public void run() {
					audioControlsNotification.clearNowPlaying();
					callbackContext.success("success");
				}
			});
    } else if (action.equals("setOptions")) {
      Log.d(TAG, "setOptions");
      // Not used yet on Android
    }
    return true;
  }

}
