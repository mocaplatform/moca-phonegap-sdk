package com.innoquant.moca.phonegap;

import android.app.Application;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.innoquant.moca.*;
import com.innoquant.moca.utils.logger.*;


import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import static com.innoquant.moca.phonegap.MOCAAPI.*;

public class MOCApp extends Application implements MOCAProximityService.EventListener, MOCAProximityService.ActionListener {

    private HashMap<String, MOCACallbackContext> callbackContextMap = new HashMap<String, MOCACallbackContext>();
    private List<MOCACordovaEvent> eventQueue;
    private Handler handler;
    private boolean isQueueingActive = true;


    @Override
    public void onCreate() {
        //android.os.Debug.waitForDebugger();
        super.onCreate();

        //Auto Init MOCA SDK
        final String appKey = MOCASharedPrefs.getAppKey(this);
        final String appSecret = MOCASharedPrefs.getAppSecret(this);
        final String gcmSenderId = MOCASharedPrefs.getGcmSenderId(this);
        if (appKey != null && appSecret != null) {
            if (!MOCA.initialized()) {
                MOCAConfig config = MOCAConfig.getDefault(appKey, appSecret);
                if (gcmSenderId != null) config.setGcmSender(gcmSenderId);
                MOCA.initializeSDK(this, config);
            }
        }
        this.startListeners();
        eventQueue = new CopyOnWriteArrayList<MOCACordovaEvent>();
    }

    public void startListeners() {
        String error = "";
        if (MOCA.initialized()) {
            MOCAProximityService proxService = MOCA.getProximityService();
            if (proxService != null) {
                proxService.setActionListener(this);
                proxService.setEventListener(this);
            }
            else {
                error = "MOCA is initialized, but proxServices returned null.";
            }
        }
        else {
            error = "MOCA is not initialized.";
        }
        MLog.wtf("Cannot listen MOCA Events. " + error);
    }

    public void addCallbackContext(String action, MOCACallbackContext callbackContext) {
        this.callbackContextMap.put(action, callbackContext);
        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        this.callbackContextMap.get(action).sendPluginResult(result);
    }

    
    /*
     * MOCA ActionListener callbacks
     */

    @Override
    public boolean displayNotificationAlert(MOCAAction mocaAction, String s) {
        return enqueueAndProcessEvent(DISPLAY_ALERT, mocaAction, s);
    }

    @Override
    public boolean openUrl(MOCAAction mocaAction, String s) {
        return enqueueAndProcessEvent(OPEN_URL, mocaAction, s);
    }

    @Override
    public boolean showHtmlWithString(MOCAAction mocaAction, String s) {
        return enqueueAndProcessEvent(SHOW_EMBEDDED_HTML, mocaAction, s);
    }

    @Override
    public boolean playVideoFromUrl(MOCAAction mocaAction, String s) {
        return enqueueAndProcessEvent(PLAY_VIDEO_FROM_URL, mocaAction, s);
    }

    @Override
    public boolean displayImageFromUrl(MOCAAction mocaAction, String s) {
        return enqueueAndProcessEvent(IMAGE_FROM_URL, mocaAction, s);
    }

    @Override
    public boolean displayPassFromUrl(MOCAAction mocaAction, String s) {
        return enqueueAndProcessEvent(PASSBOOK_FROM_URL, mocaAction, s);
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
        return enqueueAndProcessEvent(ADD_TAG, mocaAction, args);
    }

    @Override
    public boolean playNotificationSound(MOCAAction mocaAction, String s) {
        return enqueueAndProcessEvent(PLAY_NOTIFICATION_SOUND, mocaAction, s);
    }

    @Override
    public boolean performCustomAction(MOCAAction mocaAction, String s) {
        return enqueueAndProcessEvent(PERFORM_CUSTOM_ACTION, mocaAction, s);
    }
    
    
    /*
     * MOCA EventListener callbacks
     */

    @Override
    public void didEnterRange(MOCABeacon mocaBeacon, MOCAProximity mocaProximity) {
        enqueueAndProcessEvent(DID_ENTER_RANGE, mocaBeacon);
    }

    @Override
    public void didExitRange(MOCABeacon mocaBeacon) {
        enqueueAndProcessEvent(DID_EXIT_RANGE, mocaBeacon);
    }

    @Override
    public void didBeaconProximityChange(MOCABeacon beacon, MOCAProximity prevProximity, MOCAProximity curProximity) {

        JSONObject proximityChangeArgs = new JSONObject();
        try {
            JSONObject bkn = Utils.beaconToJSON(beacon);
            proximityChangeArgs.put("beacon", bkn);
            proximityChangeArgs.put("prevProximity", prevProximity.toString());
            proximityChangeArgs.put("curProximity", curProximity.toString());
            enqueueAndProcessEvent(BEACON_PROXIMITY_CHANGE, proximityChangeArgs);
        } catch (JSONException e) {
            MLog.e(BEACON_PROXIMITY_CHANGE + " callback failed. " + e);
        }
    }

    @Override
    public void didEnterPlace(MOCAPlace mocaPlace) {
        enqueueAndProcessEvent(DID_ENTER_PLACE, mocaPlace);
    }

    @Override
    public void didExitPlace(MOCAPlace mocaPlace) {
        enqueueAndProcessEvent(DID_EXIT_PLACE, mocaPlace);
    }

    @Override
    public void didEnterZone(MOCAZone mocaZone) {
        enqueueAndProcessEvent(DID_ENTER_ZONE, mocaZone);
    }

    @Override
    public void didExitZone(MOCAZone mocaZone) {
        enqueueAndProcessEvent(DID_EXIT_ZONE, mocaZone);
    }

    @Override
    public void didEnterLabel(MOCALabel mocaLabel, MOCARegion mocaRegion) {

    }

    @Override
    public void didExitLabel(MOCALabel mocaLabel, MOCARegion mocaRegion) {

    }

    @Override
    public boolean handleCustomTrigger(String s) {
        return false;
    }

    @Override
    public void didLoadedBeaconsData(List<MOCABeacon> list) {
        JSONArray beaconList = new JSONArray();
        try {
            for (MOCABeacon b : list) {
                beaconList.put(Utils.beaconToJSON(b));
            }
            enqueueAndProcessEvent(DID_LOADED_BEACONS_DATA, beaconList);
        } catch (JSONException e) {
            MLog.e(DID_LOADED_BEACONS_DATA + "callback failed: " + e);
        }
    }

    /* Event queue processing */

    /*
    Since V.2.4.4
        Discussion: As there is no signal from the JavaScript application side indicating
        MOCA SDK that all callbacks have finished their registration, it is very likely that
        during the application start up, MOCA SDK will send the events before the application have
        had time to register its callbacks, resulting in lost events in the javascript code side.

        In order to tackle this issue, the MOCA Plugin uses a queue where the events will be
        stored during some seconds after initializing the application. Afterwards, all the events
        will be processed in the same order they arrived. Subsequent events won't be enqueued
        anymore, but redirected directly to the JS code as always in order to avoid delays
        triggering proximity experiences.

        Bear in mind that if the application is launched by Android OS (or GPSS) in the background,
        cordova (ver 7 at this moment) DOES NOT create the webview, therefore, no JavScript code
        is executed at all, and callbacks won't work.
     */

    private void stopQueueingEvents() {
        isQueueingActive = false;
    }

    private void enqueueAndProcessEvent(@NonNull String eventName, @NonNull Object data) {
        enqueueAndProcessEvent(eventName, null, data);
    }

    private boolean enqueueAndProcessEvent(@NonNull String eventName,
                                           @Nullable MOCAAction mocaAction,
                                           @NonNull Object data) {
        MOCACordovaEvent mocaEvent = new MOCACordovaEvent(eventName, mocaAction, data);
        if (isQueueingActive) {
            MLog.d("Event received with name: " + eventName + ". Adding to the queue...");
            eventQueue.add(mocaEvent);
            processEnqueuedEvents();
            scheduleQueueCleaning(MOCACordovaEvent.EXPIRE_TIME_MS + 1000);
            return true; //return true for queued events (prevent MOCA from firing actions)
        } else {
            if(!eventQueue.isEmpty()) { //eventQueue is not synchronized between threads.
                processEnqueuedEvents();
            }
            MLog.d("Event received with name: " + eventName + ". No longer queueing and queue is empty. Executing...");
            return invokeCordovaCallbacksForEvent(mocaEvent);
        }
    }

    /**
     * Process the queue of events. If there is a Cordova callback associated with the event,
     * the callback is called and the action associated with the event (if any) is fired immediately.
     * Otherwise the event is left in the queue until the next cycle.
     * If the event has expired, call the cordova app callbacks (if any) and fire the actions (if any)
     */
    private void processEnqueuedEvents() {
        MLog.d("There are " + eventQueue.size() + " events in the queue. Processing queue.");
        for (MOCACordovaEvent event : eventQueue) {
            String eventName = event.getEventName();
            MLog.d("\tProcessing event: \"" + eventName + "\"");
            boolean hasCordovaCallback = cordovaAppCallbackExistForEvent(eventName);
            boolean isEventExpired = event.isExpired();
            if (hasCordovaCallback || isEventExpired) {
                MLog.d("\t\tEvent has callback -> " + (hasCordovaCallback ? "YES" : "NO"));
                MLog.d("\t\tEvent is expired -> " + (isEventExpired ? "YES" : "NO"));
                MLog.d("\t\tFiring...");
                fireEventAsync(event);
                eventQueue.remove(event);
                MLog.d("\t\tEvent removed from queue");
            }
            //otherwise leave it in the queue until next cycle.
        }
    }

    /**
     * Fire events that have been enqueued
     * @param event the MOCA generated event.
     */
    private void fireEventAsync(MOCACordovaEvent event) {
        boolean isEventBlockedByCordovaApp =
                invokeCordovaCallbacksForEvent(event);
        if (!isEventBlockedByCordovaApp) {
            MLog.d("\t\tEvent not blocked by application. Firing..");
            event.fireAction();
        }
    }

    /**
     * Cleans the event queue after expireTimeMs.
     *
     * @param expireTimeMs time until next cleaning task execution
     */
    private void scheduleQueueCleaning(long expireTimeMs) {
        if (handler != null) {
            //do not reschedule an existing scheduled cleaning task
            return;
        }
        MLog.d("Scheduling next queue clean task.");
        handler = new Handler();
        handler.postDelayed(new CleaningTask(this), expireTimeMs);
    }

    private boolean cordovaAppCallbackExistForEvent(@NonNull String eventName) {
        MOCACallbackContext callbackCtx = callbackContextMap.get(eventName);
        return callbackCtx != null;
    }

    /**
     * fires events (callbacks) in the webview
     *
     * @param mocaEvent the generated MOCA Event
     * @return the first argument sent by the webview when suscribing to callback
     * Example moca.
     */

    private boolean invokeCordovaCallbacksForEvent(@NonNull MOCACordovaEvent mocaEvent) {
        String eventName = mocaEvent.getEventName();
        Object data = mocaEvent.getData();
        MLog.d("Invoking cordova callback for event: " + eventName);
        MOCACallbackContext callbackCtx = callbackContextMap.get(eventName);
        if (callbackCtx != null) {
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
            } catch (JSONException e) {
                MLog.e(eventName + "callback failed: " + e);
            } catch (Exception e) {
                MLog.wtf("Unexpected error. " + eventName + "callback failed");
            }
        } else {
            MLog.w("No JavaScript listeners for event '" + eventName + "'");
        }
        return false;
    }

    //Helper methods
    private JSONObject getJSONFromObject(@NonNull String eventName, @NonNull Object data) throws JSONException {
        JSONObject jsonData = new JSONObject();
        if (data instanceof MOCAZone) {
            jsonData = Utils.zoneToJSON((MOCAZone) data);
        } else if (data instanceof MOCAPlace) {
            jsonData = Utils.placeToJSON((MOCAPlace) data);
        } else if (data instanceof MOCABeacon) {
            jsonData = Utils.beaconToJSON((MOCABeacon) data);
        } else if (data instanceof JSONObject) {
            jsonData = (JSONObject) data;
        } else if (data instanceof String || data instanceof JSONArray) {
            jsonData.put(eventName, data);
        } else {
            throw new JSONException("Cannot serialize data of type " + data.getClass().getName() + ", unsupported data type");
        }
        return jsonData;
    }


    private class CleaningTask implements Runnable {
        private final MOCApp app;

        CleaningTask(MOCApp mocApp) {
            app = mocApp;
        }

        @Override
        public void run() {
            MLog.d("↻ ↻ Executing Clean queue task.");
            app.stopQueueingEvents();
            app.processEnqueuedEvents();
        }
    }
}
