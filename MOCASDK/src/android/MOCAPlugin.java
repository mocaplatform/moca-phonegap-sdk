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


import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
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

import com.innoquant.moca.*;
import com.innoquant.moca.utils.MLog;

/**
 * MOCA PhoneGap Plugin for Android SDK, v2.0.0
 */
public class MOCAPlugin extends CordovaPlugin implements MOCAProximityService.EventListener, MOCAProximityService.ActionListener{

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
            MOCAAPI.CUSTOM_PROPERTY
    );

    private final static List<String> knownCallbackActions = Arrays.asList(
            MOCACallbacks.DID_ENTER_RANGE,
            MOCACallbacks.DID_EXIT_RANGE,
            MOCACallbacks.BEACON_PROXIMITY_CHANGE,
            MOCACallbacks.DID_ENTER_PLACE,
            MOCACallbacks.DID_EXIT_PLACE,
            MOCACallbacks.DID_ENTER_ZONE,
            MOCACallbacks.DID_EXIT_ZONE,
            MOCACallbacks.DISPLAY_ALERT,
            MOCACallbacks.OPEN_URL,
            MOCACallbacks.SHOW_EMBEDDED_HTML,
            MOCACallbacks.PLAY_VIDEO_FROM_URL,
            MOCACallbacks.IMAGE_FROM_URL,
            MOCACallbacks.PASSBOOK_FROM_URL,
            MOCACallbacks.ADD_TAG,
            MOCACallbacks.PLAY_NOTIFICATION_SOUND,
            MOCACallbacks.PERFORM_CUSTOM_ACTION,
            MOCACallbacks.DID_LOADED_BEACONS_DATA
    );

    private static MOCAPlugin instance;
    private ExecutorService executorService = Executors.newFixedThreadPool(1);
    private HashMap<String, MOCACallbackContext> callbackContextMap = new HashMap<String, MOCACallbackContext>();


    public MOCAPlugin () {
        instance = this;
    }


    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        MLog.i("Initializing MOCAPlugin");
        final String appKey = this.preferences.getString ("moca_app_key", null);
        if (appKey == null) {
            final String msg = "MOCA app key not specified in config.xml preferences. Missing 'moca_app_key' preference.";
            MLog.e(msg);
            throw new RuntimeException(msg);
        }
        final String appSecret = this.preferences.getString ("moca_app_secret", null);
        if (appSecret == null) {
            final String msg = "MOCA app secret not specified in config.xml preferences. Missing 'moca_app_secret' preference.";
            MLog.e(msg);
            throw new RuntimeException(msg);
        }

        // MOCAConfig config = MOCAConfig.getDefault(cordova.getActivity().getApplication());
        MOCAConfig config = MOCAConfig.getDefault(appKey, appSecret);

        final String gcmSender = this.preferences.getString("gcm_sender", null);
        if(gcmSender == null || gcmSender.trim().length() == 0) {
            final String msg = "GCM Sender not set in your config.xml preferences. Remote Push Notifications won't be available.";
            MLog.w(msg);
        }
        else {
            config.setGcmSender(gcmSender);
        }
        
        MOCA.initializeSDK(cordova.getActivity().getApplication(), config);
        if(MOCA.initialized()){
            MOCA.getProximityService().setActionListener(this);
            MOCA.getProximityService().setEventListener(this);
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
            this.callbackContextMap.put(action, new MOCACallbackContext(callbackContext, data));
            PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
            result.setKeepCallback(true);
            this.callbackContextMap.get(action).sendPluginResult(result);
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
    
    void appKey(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited(callbackContext)) return;
        final String appKey = MOCA.getAppKey();
        callbackContext.success(appKey);
    }

    void appSecret(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        final String appSecret = MOCA.getAppSecret();
        callbackContext.success(appSecret);
    }

    void initialized(JSONArray data, CallbackContext callbackContext) {
        final boolean initialized = MOCA.initialized();
        callbackContext.success(initialized ? 1 : 0);
    }

    void logLevel(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited(callbackContext)) return;
        final MOCALogLevel level = MOCA.getLogLevel();
        callbackContext.success(level.ordinal());
    }

    void getRegionStateforPlaceId(JSONArray data, CallbackContext callbackContext){
        if (!checkInited(callbackContext)) return;
        try{
            String placeId = data.getString(0);
            MOCARegionState state = MOCA.getRegionStateforPlaceId(placeId);
            callbackContext.success(state.toString());
        }
        catch (JSONException e) {
            e.printStackTrace();
        }

    }

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

    void instance_identifier(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        final MOCAInstance instance = MOCA.getInstance();
        if (instance != null)
            callbackContext.success(instance.getId());
        else 
            callbackContext.error ("MOCA instance not available");
    }

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

    void proximityEnabled(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        final boolean enabled = MOCA.proximityEnabled();
        callbackContext.success(enabled?1:0);
    }

    void setProximityEnabled(JSONArray data, CallbackContext callbackContext) {
        if (!checkInited (callbackContext)) return;
        try {
            if (data.length() < 1) {
                callbackContext.error ("Expected boolean argument");
                return;
            }
            boolean enabled = data.getBoolean (0);
            MOCA.setProximityEnabled (enabled);
            callbackContext.success();
        }
        catch (JSONException e) {
            callbackContext.error ("setProximityEnabled failed. Error: " + e.getMessage());
        }
    }

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
                return;
            } else {
                callbackContext.error ("MOCA instance not available");  
            }
        }
        catch (JSONException e) {
            callbackContext.error ("instance_userLogin failed. Error: " + e.getMessage());
        }
    }

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
                return;
            } else {
                callbackContext.error("MOCA instance not available");
            }
        }
        catch (JSONException e) {
            callbackContext.error ("instance_setCustomProperty failed. Error: " + e.getMessage());
        }
    }

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


    /*
    /* MOCA ActionListener callbacks
     */

    @Override
    public boolean displayNotificationAlert(MOCAAction mocaAction, String s) {
       return fireEvent(MOCACallbacks.DISPLAY_ALERT, s);
    }

    @Override
    public boolean openUrl(MOCAAction mocaAction, String s) {
        return fireEvent(MOCACallbacks.OPEN_URL, s);
    }

    @Override
    public boolean showHtmlWithString(MOCAAction mocaAction, String s) {
        return fireEvent(MOCACallbacks.SHOW_EMBEDDED_HTML, s);
    }

    @Override
    public boolean playVideoFromUrl(MOCAAction mocaAction, String s) {
        return fireEvent(MOCACallbacks.PLAY_VIDEO_FROM_URL, s);
    }

    @Override
    public boolean displayImageFromUrl(MOCAAction mocaAction, String s) {
        return fireEvent(MOCACallbacks.IMAGE_FROM_URL, s);
    }

    @Override
    public boolean displayPassFromUrl(MOCAAction mocaAction, String s) {
        return fireEvent(MOCACallbacks.PASSBOOK_FROM_URL, s);
    }

    @Override
    public boolean addTag(MOCAAction mocaAction, String tagName, String tagValue) {
        JSONObject args = new JSONObject();
        try {
            args.put("tagName", tagName);
            args.put("tagValue", tagValue);
        } catch (JSONException e) {
            MLog.e("addTag callback failed!");
            return false;
        }
        return fireEvent(MOCACallbacks.ADD_TAG, args);
    }

    @Override
    public boolean playNotificationSound(MOCAAction mocaAction, String s) {
        return fireEvent(MOCACallbacks.PLAY_NOTIFICATION_SOUND, s);
    }

    @Override
    public boolean performCustomAction(MOCAAction mocaAction, String s) {
        MOCACallbackContext callbackCtx = callbackContextMap.get("moca.customaction");
        if(callbackCtx != null){
            PluginResult result;
            result = new PluginResult(PluginResult.Status.OK, s);
            result.setKeepCallback(true);
            callbackCtx.sendPluginResult(result);
        }

        //old way
        try {
            JSONObject data = new JSONObject();
            data.put("customString", s);
            this.fireEvent("moca.customaction", data);
        } catch (JSONException e) {
            MLog.e("Failed perform custom action callback"+ e);
        }

        return true;
    }


    /*
    /* MOCA EventListener callbacks
     */

    @Override
    public void didEnterRange(MOCABeacon mocaBeacon, MOCAProximity mocaProximity) {
        fireEvent(MOCACallbacks.DID_ENTER_RANGE, mocaBeacon);
    }

    @Override
    public void didExitRange(MOCABeacon mocaBeacon) {
        fireEvent(MOCACallbacks.DID_EXIT_RANGE, mocaBeacon);
    }

    @Override
    public void didBeaconProximityChange(MOCABeacon beacon, MOCAProximity prevProximity, MOCAProximity curProximity) {

        JSONObject proximityChangeArgs = new JSONObject();
        try {
            JSONObject bkn = beaconToJSON(beacon);
            proximityChangeArgs.put("beacon", bkn);
            proximityChangeArgs.put("prevProximity", prevProximity.toString());
            proximityChangeArgs.put("curProximity", curProximity.toString());
            fireEvent(MOCACallbacks.BEACON_PROXIMITY_CHANGE, proximityChangeArgs);
        } catch (JSONException e) {
            MLog.e(MOCACallbacks.BEACON_PROXIMITY_CHANGE + " callback failed. " +  e);
        }
    }

    @Override
    public void didEnterPlace(MOCAPlace mocaPlace) {
        fireEvent(MOCACallbacks.DID_ENTER_PLACE, mocaPlace);
    }

    @Override
    public void didExitPlace(MOCAPlace mocaPlace) {
        fireEvent(MOCACallbacks.DID_EXIT_PLACE, mocaPlace);
    }

    @Override
    public void didEnterZone(MOCAZone mocaZone) {
        fireEvent(MOCACallbacks.DID_ENTER_ZONE, mocaZone);
    }

    @Override
    public void didExitZone(MOCAZone mocaZone) {
        fireEvent(MOCACallbacks.DID_EXIT_ZONE, mocaZone);
    }

    @Override
    public boolean handleCustomTrigger(String s) {
        return false;
    }

    @Override
    public void didLoadedBeaconsData(List<MOCABeacon> list) {
        JSONArray beaconList = new JSONArray();
        try{
            for(MOCABeacon b : list){
                beaconList.put(beaconToJSON(b));
            }
            fireEvent(MOCACallbacks.DID_LOADED_BEACONS_DATA, beaconList);
        }
        catch(JSONException e){
            MLog.e(MOCACallbacks.DID_LOADED_BEACONS_DATA + "callback failed: " + e);
        }
    }

    /**
     * fires events (callbacks) in the webview
     * @param eventName is the name of the callback (see MOCA Cordova API)
     * @param data data to be returned in the callback
     * @return the first argument sent by the webview when suscribing to callback
     * Example moca.
     */

    private boolean fireEvent(String eventName, Object data){
        MOCACallbackContext callbackCtx = callbackContextMap.get(eventName);
        if(callbackCtx != null){
            try {
                JSONObject jsonData = new JSONObject();
                if (data instanceof MOCAZone) {
                    jsonData = zoneToJSON((MOCAZone) data);
                } else if (data instanceof MOCAPlace) {
                    jsonData = placeToJSON((MOCAPlace) data);
                } else if (data instanceof MOCABeacon) {
                    jsonData = beaconToJSON((MOCABeacon) data);
                } else if(data instanceof JSONObject){
                    jsonData = (JSONObject)data;
                } else {
                    MLog.e("Invalid callback  " + eventName + ", unknown data type");
                    return false;
                }
                JSONObject event = new JSONObject();
                event.put("detail", jsonData);
                PluginResult result;
                result = new PluginResult(PluginResult.Status.OK, event);
                result.setKeepCallback(true);
                callbackCtx.sendPluginResult(result);

                //Arguments in callbacks are used to determine if MOCA should
                //show a Proximity Experience, or only send callbacks.
                JSONArray args = callbackCtx.getArgs();
                if(args != null){
                    return Boolean.parseBoolean((String) args.get(0));
                }
            }
            catch (JSONException e){
                MLog.e(eventName + "callback failed: " + e);
            }
        }
        else {
            MLog.e("Invalid callback  " + eventName);
        }
        return false;
    }

    //Helper methods
    private JSONObject beaconToJSON(MOCABeacon beacon) throws JSONException {
        if (beacon == null) return null;
        JSONObject bkn = new JSONObject();
        bkn.put("type", "beacon");
        bkn.put("id", beacon.getId());
        bkn.put("uuid", beacon.getProximityUUID().toString());
        bkn.put("major", beacon.getMajor());
        bkn.put("minor", beacon.getMinor());
        bkn.put("name", beacon.getName());
        bkn.put("proximity", beacon.getProximity().toString());
        return bkn;
    }
    private JSONObject placeToJSON(MOCAPlace mocaPlace) throws JSONException{
        if(mocaPlace == null) return null;
        JSONObject plc = new JSONObject();
        plc.put("type", "place");
        plc.put("name", mocaPlace.getName());
        plc.put("id", mocaPlace.getId());
        JSONObject gfence = new JSONObject();
        gfence.put("lat", mocaPlace.getGeoFence().getCenter().getLatitude());
        gfence.put("lon", mocaPlace.getGeoFence().getCenter().getLongitude());
        gfence.put("accuracy", mocaPlace.getGeoFence().getCenter().getAccuracy());
        plc.put("geofence", gfence);
        return plc;
    }

    private JSONObject zoneToJSON(MOCAZone mocaZone) throws JSONException{
        if(mocaZone == null) return null;
        JSONObject zn = new JSONObject();
        zn.put("type", "zone");
        zn.put("id", mocaZone.getId());
        zn.put("name", mocaZone.getName());
        return zn;
    }

}



