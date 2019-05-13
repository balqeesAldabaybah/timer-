package com.example.flutterapptimer;

import android.app.Service;
import java.lang.*;
import java.lang.Object;
import android.content.Intent;
import android.os.IBinder;
import android.media.MediaPlayer;
import android.os.CountDownTimer;
import android.util.Log;
public class background extends  Service{

    private MediaPlayer player;
    @Override
    public IBinder onBind(Intent intent){
        return null;
    }


    @Override
    public int onStartCommand(Intent intent, int flags, int startID){
         String value = intent.getStringExtra("value");
         if(value == "r"){
             player.stop();
             return 0;
         }
         int IntValue = Integer.valueOf(value);
        Log.i("T"," AndroidValueeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee" + value);
        new CountDownTimer(IntValue*1000,1000){
            public void onTick(long t){}
            public void onFinish(){
                player = MediaPlayer.create(background.this,R.raw.sound_alarm_1);
                player.start();       
            }
        }.start();
                                                                    
        return START_STICKY;
            
    }

    @Override
    public void onDestroy(){
        super.onDestroy();
        player.stop();
    }
}