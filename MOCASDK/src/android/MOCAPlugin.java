//
//  MOCAPlugin.java
//
//  MOCA PhoneGap SDK for Android
//
//  This module is part of InnoQuant MOCA Platform.
//
//  Copyright (c) 2014-2015 InnoQuant Strategic Analytics, S.L.
//  All rights reserved.
//
//  All rights to this software by InnoQuant are owned by InnoQuant
//  and only limited rights are provided by the licensing or contract
//  under which this software is provided.
//
//  Any use of the software for any commercial purpose without
//  the written permission of InnoQuant is prohibited.
//  You may not alter, modify, or in any way change the appearance
//  and copyright notices on the software. You may not reverse compile
//  the software or publish any protected intellectual property embedded
//  in the software. You may not distribute, sell or make copies of
//  the software available to any entities without the explicit written
//  permission of InnoQuant.
//

package com.innoquant.moca.phonegap;


import android.app.Application;

import com.innoquant.moca.MOCA;
import com.innoquant.moca.MOCACallback;
import com.innoquant.moca.MOCAConfig;
import com.innoquant.moca.MOCAException;
import com.innoquant.moca.MOCAInstance;
import com.innoquant.moca.MOCALogLevel;
import com.innoquant.moca.MOCAPlace;
import com.innoquant.moca.MOCARegionState;
import com.innoquant.moca.MOCAUser;
import com.innoquant.moca.proximity.ProximityData;
import com.innoquant.moca.utils.MLog;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * MOCA PhoneGap Plugin for Android SDK, v2.0.1
 */
public class MOCAPlugin extends CordovaPlugin {

    private final static List<String> knownActions = Arrays.asList(
            MOCAAPI.SET_LOG_LEVEL,
            MOCAAPI.VERSION,
            MOCAAPI.APP_KEY,
            MOCAAPI.APP_SECRET,
            MOCAAPI.INIT,
            MOCAAPI.LOG_LEVEL,
            MOCAAPI.INSTANCE_SESSION,
            MOCAAPI.INSTANCE_IDENTIFIER,
            MOCAAPI.PROXIMITY_ENABLED,
            MOCAAPI.SET_PROXIMITY_ENABLED,
            MOCAAPI.INSTANCE_USER_LOGIN,
            MOCAAPI.INSTANCE_USER_LOGGED_IN,
            MOCAAPI.INSTANCE_USER_LOGOUT,
            MOCAAPI.INSTANCE_SET_CUSTOM_PROPERTY,
            MOCAAPI.INSTANCE_CUSTOM_PROPERTY,
            MOCAAPI.CUSTOM_PROPERTY,
            MOCAAPI.PLACES_INSIDE,
            MOCAAPI.SET_GEOTRACKING_ENABLED,
            MOCAAPI.PERFORM_FETCH
    );

    private final static List<String> knownCallbackActions = Arrays.asList(
            MOCAConstants.DID_ENTER_RANGE,
            MOCAConstants.DID_EXIT_RANGE,
            MOCAConstants.BEACON_PROXIMITY_CHANGE,
            MOCAConstants.DID_ENTER_PLACE,
            MOCAConstants.DID_EXIT_PLACE,
            MOCAConstants.DID_ENTER_ZONE,
            MOCAConstants.DID_EXIT_ZONE,
            MOCAConstants.DISPLAY_ALERT,
            MOCAConstants.OPEN_URL,
            MOCAConstants.SHOW_EMBEDDED_HTML,
            MOCAConstants.PLAY_VIDEO_FROM_URL,
            MOCAConstants.IMAGE_FROM_URL,
            MOCAConstants.PASSBOOK_FROM_URL,
            MOCAConstants.ADD_TAG,
            MOCAConstants.PLAY_NOTIFICATION_SOUND,
            MOCAConstants.PERFORM_CUSTOM_ACTION,
            MOCAConstants.DID_LOADED_BEACONS_DATA
    );

    private static MOCAPlugin instance;
    private ExecutorService executorService = Executors.newFixedThreadPool(1);


    public MOCAPlugin () {
        instance = this;
    }


    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        MLog.i("Initializing MOCAPlugin");
        if(!MOCA.initialized()) {
            //MOCA Init after cordova plugin init
            final String appKey = this.preferences.getString(MOCAConstants.APP_KEY, null);
            if (appKey == null) {
                final String msg = "MOCA app key not specified in config.xml preferences. Missing 'moca_app_key' preference.";
                MLog.e(msg);
                throw new RuntimeException(msg);
            }
            final String appSecret = this.preferences.getString(MOCAConstants.APP_SECRET, null);
            if (appSecret == null) {
                final String msg = "MOCA app secret not specified in config.xml preferences. Missing 'moca_app_secret' preference.";
                MLog.e(msg);
                throw new RuntimeException(msg);
            }

            // MOCAConfig config = MOCAConfig.getDefault(cordova.getActivity().getApplication());
            MOCAConfig config = MOCAConfig.getDefault(appKey, appSecret);

            final String gcmSender = this.preferences.getString("gcm_sender", null);
            if (gcmSender == null || gcmSender.trim().length() == 0) {
                final String msg = "GCM Sender not set in your config.xml preferences. Remote Push Notifications won't be available.";
                MLog.w(msg);
            } else {
                config.setGcmSender(gcmSender);
            }
            MOCASharedPrefs.persistValues(appKey, appSecret, gcmSender, cordova.getActivity().getApplicationContext());
            MOCA.initializeSDK(cordova.getActivity().getApplication(), config);

            Application app = cordova.getActivity().getApplication();
            ((MOCApp)app).startListeners();
        }
    }



    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
    }

    @Override
    public boolean execute(final String action, final JSONArray data, final CallbackContext callbackContext) {

        if (!knownActions.contains(action) && !knownCallbackActions.contains(action)) {
            MLog.e("Invalid action: " + action);
            return false;
        }
        if(knownCallbackActions.contains(action) && checkInited(callbackContext)){
            Application app = cordova.getActivity().getApplication();
            ((MOCApp)app).addCallbackContext(action, new MOCACallbackContext(callbackContext, data));
            return true;
        }
        executorService.execute(new Runnable() {

            @Override
            public void run() {
                try {
                    MLog.d("Plugin Execute: " + action);
                    Method method = MOCAPlugin.class.getDeclaredMethod(action, JSONArray.class, CallbackContext.class);
                    method.invoke(MOCAPlugin.this, data, callbackContext);
                } catch (Exception e) {
                    MLog.e("Plugin execute failed", e);
                }
            }
        });
        return true;
    }

    @SuppressWarnings("unused")
    void version(JSONArray data, CallbackContext callbackContext) {
        final String version = MOCA.getVersion();
        callbackContext.success(version);
    }

    private boolean checkInited (CallbackContext callbackContext) {
        if (!MOCA.initialized()) {
            callbackContext.error("MOCA not initialized");
            return false;
        }
        return true;
    }

    @SuppressWarnings("unused")
    void appKey(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited(callbackContext)) return;
        final String appKey = MOCA.getAppKey();
        callbackContext.success(appKey);
    }

    @SuppressWarnings("unused")
    void appSecret(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        final String appSecret = MOCA.getAppSecret();
        callbackContext.success(appSecret);
    }

    @SuppressWarnings("unused")
    void initialized(JSONArray data, CallbackContext callbackContext) {
        final boolean initialized = MOCA.initialized();
        callbackContext.success(initialized ? 1 : 0);
    }

    @SuppressWarnings("unused")
    void logLevel(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited(callbackContext)) return;
        final MOCALogLevel level = MOCA.getLogLevel();
        callbackContext.success(level.ordinal());
    }

    @SuppressWarnings("unused")
    void instance_session(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        final MOCAInstance instance = MOCA.getInstance();
        if (instance != null) {
            final int sessionNumber = (int)instance.getSessionNumber();
            callbackContext.success(sessionNumber);
        }
        else {
            callbackContext.error ("MOCA instance not available");
        }
    }

    @SuppressWarnings("unused")
    void instance_identifier(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        final MOCAInstance instance = MOCA.getInstance();
        if (instance != null)
            callbackContext.success(instance.getId());
        else 
            callbackContext.error ("MOCA instance not available");
    }

    @SuppressWarnings("unused")
    void setLogLevel(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        try {
            String level = data.getString (0);
            if (level == null || level.length () == 0) {
                level = "Info";
            }
            MOCALogLevel newLevel = MOCALogLevel.valueOf(level);
            if (newLevel == null) {
                callbackContext.error ("Invalid log level " + level);
                return;
            }
            MLog.setLogLevel (newLevel);
            callbackContext.success();
        }
        catch (JSONException e) {
            callbackContext.error("setLogLevel failed. Error: " + e.getMessage());
        }
    }

    @SuppressWarnings("unused")
    void proximityEnabled(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        final boolean enabled = MOCA.proximityEnabled();
        callbackContext.success(enabled?1:0);
    }

    @SuppressWarnings("unused")
    void setProximityEnabled(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        try {
            if (data.length() < 1) {
                callbackContext.error ("Expected boolean argument");
                return;
            }
            boolean enabled = data.getJSONArray(0).getBoolean(0);
            MOCA.setProximityEnabled (enabled);
            callbackContext.success();
        }
        catch (JSONException e) {
            callbackContext.error ("setProximityEnabled failed. Error: " + e.getMessage());
        }
    }

    @SuppressWarnings("unused")
    void setGeoTrackingEnabled(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        try {
            if (data.length() < 1) {
                callbackContext.error ("Expected boolean argument");
                return;
            }
            boolean enabled = data.getJSONArray(0).getBoolean(0);
            MOCA.setGeoTrackingEnabled (enabled);
            callbackContext.success();
        }
        catch (JSONException e) {
            callbackContext.error ("setGeoTrackingEnabled failed. Error: " + e.getMessage());
        }
    }

    @SuppressWarnings("unused")
    void instance_userLoggedIn(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        final MOCAInstance instance = MOCA.getInstance ();
        if (instance != null) {
            final MOCAUser user = instance.getUser(); 
            callbackContext.success(user != null ? 1 : 0);  
            return;
        }
        callbackContext.error ("MOCA instance not available");
    }

    @SuppressWarnings("unused")
    void instance_userLogin(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        try {
            if (data.length() < 1) {
                callbackContext.error ("Expected string argument");
                return;
            }
            final String userId = data.getString(0);
            if (userId == null) {
                callbackContext.error ("Expected non null userId");    
                return;
            }
            final MOCAInstance instance = MOCA.getInstance ();
            if (instance != null) {
                instance.login (userId);
                callbackContext.success();
            } else {
                callbackContext.error ("MOCA instance not available");  
            }
        }
        catch (JSONException e) {
            callbackContext.error ("instance_userLogin failed. Error: " + e.getMessage());
        }
    }

    @SuppressWarnings("unused")
    void instance_userLogout(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        try {
            final MOCAInstance instance = MOCA.getInstance();
            if (instance != null) {
                MOCAUser user = instance.getUser ();
                if (user != null) {
                    user.logout ();
                }
                callbackContext.success();
            } else {
                callbackContext.error("MOCA instance not available");
            }
        }
        catch (Exception e) {
            callbackContext.error ("instance_userLogout failed. Error: " + e.getMessage());
        }
    }

    @SuppressWarnings("unused")
    void instance_setCustomProperty(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        try {
            if (data.length() < 2) {
                callbackContext.error ("Expected key and value arguments");
                return;
            }
            final String key = data.getString(0);
            if (key == null) {
                callbackContext.error ("Expected non null property key");    
                return;
            }
            final Object value = data.get(1);
            final MOCAInstance instance = MOCA.getInstance ();
            if (instance != null) {
                instance.setProperty (key, value);
                callbackContext.success();
            } else {
                callbackContext.error("MOCA instance not available");
            }
        }
        catch (JSONException e) {
            callbackContext.error ("instance_setCustomProperty failed. Error: " + e.getMessage());
        }
    }

    @SuppressWarnings("unused")
    void instance_customProperty(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        try {
            if (data.length() < 1) {
                    callbackContext.error ("Expected property key argument");
                    return;
            }
            final String key = data.getString(0);
            if (key == null) {
                callbackContext.error ("Expected non null property key");    
                return;
            }
            final MOCAInstance instance = MOCA.getInstance ();
            if (instance != null) {
                final Object value = instance.getProperty (key);
                Map<String,Object> result = new HashMap<String,Object>();
                result.put(key, value);
                JSONObject jObj = new JSONObject (result);
                callbackContext.success(jObj);
                return;
            }
            callbackContext.error ("MOCA instance not available");
        } catch (JSONException e) {
            callbackContext.error ("instance_customProperty failed. Error: " + e.getMessage());
        }
    }

    @SuppressWarnings("unused")
    void placesInside(JSONArray data, CallbackContext callbackContext){
        if (!checkInited (callbackContext)) return;
        List<MOCAPlace> places = MOCA.getProximityService().getPlaces();
        JSONArray arr = new JSONArray();
        for(MOCAPlace p : places){
            if (p.getCurrentState() == MOCARegionState.Inside){
                try {
                    arr.put(Utils.placeToJSON(p));
                } catch (JSONException e) {
                    callbackContext.error("Cannot get places inside");
                }
            }
        }
        callbackContext.success(arr);
    }

    void performFetch(JSONArray data, final CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;

        MOCA.performFetchWithCallback(new MOCACallback<ProximityData>() {
            @Override
            public void success(ProximityData proximityData) {
                callbackContext.success();
            }

            @Override
            public void failure(MOCAException e) {
                callbackContext.error(e.getMessage());
            }
        });

    }


}



