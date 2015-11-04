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


import android.content.Context;
import android.os.RemoteException;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.msgpack.util.json.JSON;
import org.msgpack.util.json.JSONBufferPacker;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.innoquant.moca.*;
import com.innoquant.moca.utils.MLog;

/**
 * MOCA PhoneGap Plugin for Android SDK, v1.8.4
 */
public class MOCAPlugin extends CordovaPlugin implements MOCAProximityService.EventListener, MOCAProximityService.ActionListener{

    private final static List<String> knownActions = Arrays.asList("setLogLevel", "version", "appKey", "appSecret", "initialized",
            "logLevel", "instance_session", "instance_identifier", "proximityEnabled", "setProximityEnabled", 
            "instance_userLogin", "instance_userLoggedIn", "instance_userLogout", "instance_setCustomProperty",
            "instance_customProperty", "customProperty", "getRegionStateforPlaceId");

    private final static List<String> knownCallbackActions = Arrays.asList("moca.enterbeacon", "moca.exitbeacon",
            "moca.beaconproximitychange", "moca.enterplace", "moca.exitplace", "moca.enterzone",
            "moca.exitzone", "moca.customaction");

    private static MOCAPlugin instance;
    private ExecutorService executorService = Executors.newFixedThreadPool(1);
    private HashMap<String, CallbackContext> callbackContext = new HashMap<String, CallbackContext>();


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
            this.callbackContext.put(action, callbackContext);
            PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
            result.setKeepCallback(true);
            this.callbackContext.get(action).sendPluginResult(result);
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
        final String version = MOCA.getVersion ();
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
            callbackContext.error ("setLogLevel failed. Error: " + e.getMessage());
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
            final MOCAInstance instance = MOCA.getInstance ();
            if (instance != null) {
                MOCAUser user = instance.getUser ();
                if (user != null) {
                    user.logout ();
                }
                callbackContext.success();
            } else {
                callbackContext.error ("MOCA instance not available");  
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
        return false;
    }

    @Override
    public boolean openUrl(MOCAAction mocaAction, String s) {
        return false;
    }

    @Override
    public boolean showHtmlWithString(MOCAAction mocaAction, String s) {
        return false;
    }

    @Override
    public boolean playVideoFromUrl(MOCAAction mocaAction, String s) {
        return false;
    }

    @Override
    public boolean displayImageFromUrl(MOCAAction mocaAction, String s) {
        return false;
    }

    @Override
    public boolean displayPassFromUrl(MOCAAction mocaAction, String s) {
        return false;
    }

    @Override
    public boolean addTag(MOCAAction mocaAction, String s, String s1) {
        return false;
    }

    @Override
    public boolean playNotificationSound(MOCAAction mocaAction, String s) {
        return false;
    }

    @Override
    public boolean performCustomAction(MOCAAction mocaAction, String s) {
        CallbackContext callbackCtx = callbackContext.get("moca.customaction");
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
        //new JS -> Java bridge
        //TODO: Use this implementation instead "sendJavascript"
        CallbackContext callbackCtx = callbackContext.get("moca.enterbeacon");
        if(callbackCtx != null){
            PluginResult result;
            try {
                result = new PluginResult(PluginResult.Status.OK, beaconToJSON(mocaBeacon));
                result.setKeepCallback(true);
                callbackCtx.sendPluginResult(result);
            } catch (JSONException e) {
                MLog.e("Failed EnterBeacon callback" + e);
            }
            return;
        }

        //old way
        try {
            this.fireEvent("moca.enterbeacon", beaconToJSON(mocaBeacon));
        } catch (JSONException e) {
            MLog.e("Failed EnterBeacon callback" + e);
        }

    }

    @Override
    public void didExitRange(MOCABeacon mocaBeacon) {
        CallbackContext callbackCtx = callbackContext.get("moca.exitbeacon");
        if(callbackCtx != null){
            PluginResult result;
            try {
                result = new PluginResult(PluginResult.Status.OK, beaconToJSON(mocaBeacon));
                result.setKeepCallback(true);
                callbackCtx.sendPluginResult(result);
            } catch (JSONException e) {
                MLog.e("Failed ExitBeacon callback" + e);
            }
        }

        //old way
        try {
            this.fireEvent("moca.exitbeacon", beaconToJSON(mocaBeacon));
        } catch (JSONException e) {
            MLog.e("Exit beacon callback failed" + e);
        }

    }

    @Override
    public void didBeaconProximityChange(MOCABeacon beacon, MOCAProximity prevProximity, MOCAProximity curProximity) {
        CallbackContext callbackCtx = callbackContext.get("moca.beaconproximitychange");
        if(callbackCtx != null){
            JSONObject proximityChangeArgs = new JSONObject();
            JSONObject bkn = new JSONObject();
            try {
                proximityChangeArgs.put("beacon", bkn);
                proximityChangeArgs.put("prevProximity", prevProximity);
                proximityChangeArgs.put("curProximity", curProximity);
            } catch (JSONException e) {
                MLog.e("Beacon proximity change callback failed. " +  e);
            }
            PluginResult result = new PluginResult(PluginResult.Status.OK, proximityChangeArgs);
            result.setKeepCallback(true);
            callbackCtx.sendPluginResult(result);
        }

        //old way
        JSONObject proximityChangeArgs = new JSONObject();
        try {
            proximityChangeArgs.put("beacon", beaconToJSON(beacon));
            proximityChangeArgs.put("prevProximity", prevProximity);
            proximityChangeArgs.put("curProximity", curProximity);
            this.fireEvent("moca.beaconproximitychange", proximityChangeArgs);
        } catch (JSONException e) {
            MLog.e("Beacon proximity change callback failed. " +  e);
        }
    }

    @Override
    public void didEnterPlace(MOCAPlace mocaPlace) {
        CallbackContext callbackCtx = callbackContext.get("moca.enterplace");
        if(callbackCtx != null){
            PluginResult result;
            try {
                result = new PluginResult(PluginResult.Status.OK, placeToJSON(mocaPlace));
                result.setKeepCallback(true);
                callbackCtx.sendPluginResult(result);
            } catch (JSONException e) {
                MLog.e("Enter Place callback failed" + e);
            }
        }

        //old way
        try {
            this.fireEvent("moca.enterplace", placeToJSON(mocaPlace));
        }
        catch(JSONException e){
            MLog.e("Enter Place callback failed" + e);
        }
    }

    @Override
    public void didExitPlace(MOCAPlace mocaPlace) {
        CallbackContext callbackCtx = callbackContext.get("moca.exitplace");
        if(callbackCtx != null){
            PluginResult result;
            try {
                result = new PluginResult(PluginResult.Status.OK, placeToJSON(mocaPlace));
                result.setKeepCallback(true);
                callbackCtx.sendPluginResult(result);
            } catch (JSONException e) {
                MLog.e("Exit place callback failed" + e);
            }
        }

        //old way
        try {
            this.fireEvent("moca.exitplace", placeToJSON(mocaPlace));
        }
        catch(JSONException e){
            MLog.e("Exit Place callback failed" + e);
        }
    }

    @Override
    public void didEnterZone(MOCAZone mocaZone) {
        CallbackContext callbackCtx = callbackContext.get("moca.enterzone");
        if(callbackCtx != null){
            PluginResult result;
            try {
                result = new PluginResult(PluginResult.Status.OK, zoneToJSON(mocaZone));
                result.setKeepCallback(true);
                callbackCtx.sendPluginResult(result);
            } catch (JSONException e) {
                MLog.e("Enter zone callback failed" + e);
            }
        }

        //old way
        try {
            this.fireEvent("moca.enterzone", zoneToJSON(mocaZone));
        }
        catch(JSONException e){
            MLog.e("Enter Zone callback failed" + e);
        }
    }

       @Override
    public void didExitZone(MOCAZone mocaZone) {
           CallbackContext callbackCtx = callbackContext.get("moca.exitzone");
           if(callbackCtx != null){
               PluginResult result;
               try {
                   result = new PluginResult(PluginResult.Status.OK, zoneToJSON(mocaZone));
                   result.setKeepCallback(true);
                   callbackCtx.sendPluginResult(result);
               } catch (JSONException e) {
                   MLog.e("Exit zone callback failed" + e);
               }
           }


           //old way
           try {
               this.fireEvent("moca.exitzone", zoneToJSON(mocaZone));
           }
           catch(JSONException e){
               MLog.e("Exit Zone callback failed" + e);
           }
    }

    @Override
    public boolean handleCustomTrigger(String s) {
        return false;
    }

    @Override
    public void didLoadedBeaconsData(List<MOCABeacon> list) {

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
        bkn.put("zone", zoneToJSON(beacon.getZone()));
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
        zn.put("Place", placeToJSON(mocaZone.getPlace()));
        JSONObject bkns = new JSONObject();
        for (MOCABeacon beacon: mocaZone.getBeacons()){
            bkns.put(beacon.getName(), beaconToJSON(beacon));
        }
        zn.put("beacons", bkns);
        return zn;
    }

    private void fireEvent(String eventName, JSONObject data){
        JSONObject event = new JSONObject();
        try {
            event.put("detail", data);
            String statement = "cordova.fireDocumentEvent('"+ eventName +"',"+ event.toString()  +");";
            this.webView.sendJavascript(statement);
        } catch (JSONException e) {
            MLog.e(eventName + "callback failed: " + e);
        }
    }

}



