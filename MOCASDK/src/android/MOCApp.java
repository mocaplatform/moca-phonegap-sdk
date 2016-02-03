package com.innoquant.moca.phonegap;

import android.app.Application;

import com.innoquant.moca.MOCA;
import com.innoquant.moca.MOCAAction;
import com.innoquant.moca.MOCABeacon;
import com.innoquant.moca.MOCAConfig;
import com.innoquant.moca.MOCAPlace;
import com.innoquant.moca.MOCAProximity;
import com.innoquant.moca.MOCAProximityService;
import com.innoquant.moca.MOCAZone;
import com.innoquant.moca.utils.MLog;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;

/**
 * Created by tomacco on 21/11/15.
 */
public class MOCApp extends Application implements MOCAProximityService.EventListener, MOCAProximityService.ActionListener{

    private HashMap<String, MOCACallbackContext> callbackContextMap = new HashMap<String, MOCACallbackContext>();


    @Override
    public void onCreate() {
//        android.os.Debug.waitForDebugger();

        super.onCreate();

        //Auto Init MOCA SDK
        final String appKey = MOCASharedPrefs.getAppKey(this);
        final String appSecret = MOCASharedPrefs.getAppSecret(this);
        final String gcmSenderId = MOCASharedPrefs.getGcmSenderId(this);
        if(appKey != null && appSecret != null){
            if(!MOCA.initialized()){
                MOCAConfig config = MOCAConfig.getDefault(appKey, appSecret);
                if(gcmSenderId != null) config.setGcmSender(gcmSenderId);
                MOCA.initializeSDK(this, config);
            }
        }
        this.startListeners();
    }

    public void startListeners(){
        if(MOCA.initialized()){
            MOCA.getProximityService().setActionListener(this);
            MOCA.getProximityService().setEventListener(this);
        }
        else{
            MLog.wtf("Cannot listen MOCA Events. MOCA is not running.");
        }
    }

    public void addCallbackContext(String action, MOCACallbackContext callbackContext){
        this.callbackContextMap.put(action, callbackContext);
        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        this.callbackContextMap.get(action).sendPluginResult(result);
    }



    /*
    /* MOCA ActionListener callbacks
     */

    @Override
    public boolean displayNotificationAlert(MOCAAction mocaAction, String s) {
        return fireEvent(MOCAConstants.DISPLAY_ALERT, s);
    }

    @Override
    public boolean openUrl(MOCAAction mocaAction, String s) {
        return fireEvent(MOCAConstants.OPEN_URL, s);
    }

    @Override
    public boolean showHtmlWithString(MOCAAction mocaAction, String s) {
        return fireEvent(MOCAConstants.SHOW_EMBEDDED_HTML, s);
    }

    @Override
    public boolean playVideoFromUrl(MOCAAction mocaAction, String s) {
        return fireEvent(MOCAConstants.PLAY_VIDEO_FROM_URL, s);
    }

    @Override
    public boolean displayImageFromUrl(MOCAAction mocaAction, String s) {
        return fireEvent(MOCAConstants.IMAGE_FROM_URL, s);
    }

    @Override
    public boolean displayPassFromUrl(MOCAAction mocaAction, String s) {
        return fireEvent(MOCAConstants.PASSBOOK_FROM_URL, s);
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
        return fireEvent(MOCAConstants.ADD_TAG, args);
    }

    @Override
    public boolean playNotificationSound(MOCAAction mocaAction, String s) {
        return fireEvent(MOCAConstants.PLAY_NOTIFICATION_SOUND, s);
    }

    @Override
    public boolean performCustomAction(MOCAAction mocaAction, String s) {
        return fireEvent(MOCAConstants.PERFORM_CUSTOM_ACTION, s);
    }


    /*
    /* MOCA EventListener callbacks
     */

    @Override
    public void didEnterRange(MOCABeacon mocaBeacon, MOCAProximity mocaProximity) {
        fireEvent(MOCAConstants.DID_ENTER_RANGE, mocaBeacon);
    }

    @Override
    public void didExitRange(MOCABeacon mocaBeacon) {
        fireEvent(MOCAConstants.DID_EXIT_RANGE, mocaBeacon);
    }

    @Override
    public void didBeaconProximityChange(MOCABeacon beacon, MOCAProximity prevProximity, MOCAProximity curProximity) {

        JSONObject proximityChangeArgs = new JSONObject();
        try {
            JSONObject bkn = Utils.beaconToJSON(beacon);
            proximityChangeArgs.put("beacon", bkn);
            proximityChangeArgs.put("prevProximity", prevProximity.toString());
            proximityChangeArgs.put("curProximity", curProximity.toString());
            fireEvent(MOCAConstants.BEACON_PROXIMITY_CHANGE, proximityChangeArgs);
        } catch (JSONException e) {
            MLog.e(MOCAConstants.BEACON_PROXIMITY_CHANGE + " callback failed. " +  e);
        }
    }

    @Override
    public void didEnterPlace(MOCAPlace mocaPlace) {
        fireEvent(MOCAConstants.DID_ENTER_PLACE, mocaPlace);
    }

    @Override
    public void didExitPlace(MOCAPlace mocaPlace) {
        fireEvent(MOCAConstants.DID_EXIT_PLACE, mocaPlace);
    }

    @Override
    public void didEnterZone(MOCAZone mocaZone) {
        fireEvent(MOCAConstants.DID_ENTER_ZONE, mocaZone);
    }

    @Override
    public void didExitZone(MOCAZone mocaZone) {
        fireEvent(MOCAConstants.DID_EXIT_ZONE, mocaZone);
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
                beaconList.put(Utils.beaconToJSON(b));
            }
            fireEvent(MOCAConstants.DID_LOADED_BEACONS_DATA, beaconList);
        }
        catch(JSONException e){
            MLog.e(MOCAConstants.DID_LOADED_BEACONS_DATA + "callback failed: " + e);
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
                JSONObject event = new JSONObject();
                event.put("detail", getJSONFromObject(eventName, data));
                PluginResult result;
                result = new PluginResult(PluginResult.Status.OK, event);
                result.setKeepCallback(true);
                callbackCtx.sendPluginResult(result);

                //Arguments in callbacks are used to determine if MOCA should
                //show a Proximity Experience, or only send callbacks.
                return callbackCtx.getBooleanArg();
            }
            catch (JSONException e){
                MLog.e(eventName + "callback failed: " + e);
            }
            catch(Exception e){
                MLog.wtf("Unexpected error. " + eventName + "callback failed");
            }
        }
        else {
            MLog.w("No JavaScript listeners for  " + eventName);
        }
        return false;
    }

    //Helper methods
    private JSONObject getJSONFromObject(String eventName, Object data) throws JSONException{
        JSONObject jsonData = new JSONObject();
        if (data instanceof MOCAZone) {
            jsonData = Utils.zoneToJSON((MOCAZone) data);
        } else if (data instanceof MOCAPlace) {
            jsonData = Utils.placeToJSON((MOCAPlace) data);
        } else if (data instanceof MOCABeacon) {
            jsonData = Utils.beaconToJSON((MOCABeacon) data);
        } else if(data instanceof JSONObject){
            jsonData = (JSONObject)data;
        } else if(data instanceof String || data instanceof JSONArray){
            jsonData.put(eventName, data);
        }else {
            throw new JSONException("Cannot converto to JSONObject, unknown data type");
        }
        return jsonData;
    }


}
