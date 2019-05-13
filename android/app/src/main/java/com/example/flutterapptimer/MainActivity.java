package com.example.flutterapptimer;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.lang.*;
import android.media.MediaPlayer;
import android.os.AsyncTask;
import android.content.Intent;
import android.util.Log;

public class MainActivity extends FlutterActivity {
  private static final String Channel = "runAlarm";
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

   
    
    new MethodChannel(getFlutterView(), Channel).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if(call.method.equals("playAlarm")){
                          String value = call.argument("value");
                          int x = playAlarm(value);
                          if(x==1){
                            result.success(x);
                          }else{
                            result.error("unavailable","can not run the alarm ",null);
                          }
                        }else{
                          result.notImplemented();
                        }
                    }
                });
  }
  private int playAlarm(String value){
    if(Integer.valueOf(value)!=0){
      Intent intent = new Intent(MainActivity.this,background.class);
      intent.putExtra("value", value);
      Log.i("T"," AndroidValueeeeeeeeeMainActivityeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee" + value);
      startService(intent);
      return 1;
    }else {
      return 0;
    }
     
  }
}



