package com.innoquant.moca.phonegap;


public class MOCAConstants {
    //Event callbacks
    public static final String DID_ENTER_RANGE = "enterBeacon";
    public static final String DID_EXIT_RANGE = "exitBeacon";
    public static final String BEACON_PROXIMITY_CHANGE = "beaconProximityChange";
    public static final String DID_ENTER_PLACE = "enterPlace";
    public static final String DID_EXIT_PLACE = "exitPlace";
    public static final String DID_ENTER_ZONE = "enterZone";
    public static final String DID_EXIT_ZONE = "exitZone";


    //Action callbacks
    public static final String DISPLAY_ALERT = "displayAlert";
    public static final String OPEN_URL = "openUrl";
    public static final String SHOW_EMBEDDED_HTML = "showEmbeddedHtml";
    public static final String PLAY_VIDEO_FROM_URL = "playVideo";
    public static final String IMAGE_FROM_URL = "showImage";
    public static final String PASSBOOK_FROM_URL = "addPassbook";
    public static final String ADD_TAG = "addTag";
    public static final String PLAY_NOTIFICATION_SOUND = "playSound";
    public static final String PERFORM_CUSTOM_ACTION = "customAction";

    //Other callbacks
    public static final String DID_LOADED_BEACONS_DATA = "didLoadedBeaconsData";

    //Other constants
    public static final String APP_KEY = "moca_app_key";
    public static final String APP_SECRET = "moca_app_secret";


    public static final String GCM_SENDER_ID = "gcm_sender_id";
}
