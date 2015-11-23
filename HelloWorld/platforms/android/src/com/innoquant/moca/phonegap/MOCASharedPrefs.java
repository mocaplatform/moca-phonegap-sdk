package com.innoquant.moca.phonegap;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * Created by jday on 23/11/15.
 */
public class MOCASharedPrefs {

    private static final String PREFS_FILE = "prefs_file";

    public static void persistValues(String appKey, String appSecret, String gcmSender, Context context) {
        SharedPreferences.Editor editor = context.getSharedPreferences(PREFS_FILE, Context.MODE_PRIVATE).edit();
        editor.putString(MOCAConstants.APP_KEY, appKey);
        editor.putString(MOCAConstants.APP_SECRET, appSecret);
        editor.putString(MOCAConstants.GCM_SENDER_ID, gcmSender);
        editor.apply();
    }

    public static String getAppKey(Context context){
        SharedPreferences prefs = getSharedPrefs(context);
        return prefs.getString(MOCAConstants.APP_KEY, null);
    }

    public static String getAppSecret(Context context){
        SharedPreferences prefs = getSharedPrefs(context);
        return prefs.getString(MOCAConstants.APP_SECRET, null);
    }
    public static String getGcmSenderId(Context context){
        SharedPreferences prefs = getSharedPrefs(context);
        return prefs.getString(MOCAConstants.GCM_SENDER_ID, null);
    }


    public static SharedPreferences getSharedPrefs(Context context) {
        return context.getSharedPreferences(PREFS_FILE, Context.MODE_PRIVATE);
    }
}
