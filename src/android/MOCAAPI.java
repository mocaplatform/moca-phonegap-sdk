package com.innoquant.moca.phonegap;

import java.util.Arrays;
import java.util.List;

public class MOCAAPI {
    private static final String SET_LOG_LEVEL = "setLogLevel";
    public static final String VERSION = "version";
    private static final String APP_KEY = "appKey";
    private static final String APP_SECRET = "appSecret";
    private static final String INIT = "initialized";
    private static final String LOG_LEVEL = "logLevel";
    private static final String INSTANCE_SESSION = "instance_session";
    private static final String INSTANCE_IDENTIFIER = "instance_identifier";
    private static final String PROXIMITY_ENABLED = "proximityEnabled";
    private static final String SET_PROXIMITY_ENABLED = "setProximityEnabled";
    private static final String SET_GEOTRACKING_ENABLED = "setGeoTrackingEnabled";
    private static final String INSTANCE_USER_LOGIN = "instance_userLogin";
    private static final String INSTANCE_USER_LOGGED_IN = "instance_userLoggedIn";
    private static final String INSTANCE_USER_LOGOUT = "instance_userLogout";
    private static final String INSTANCE_SET_CUSTOM_PROPERTY = "instance_setCustomProperty";
    private static final String INSTANCE_CUSTOM_PROPERTY = "instance_customProperty";
    private static final String CUSTOM_PROPERTY = "customProperty";
    private static final String PLACES_INSIDE = "placesInside";
    private static final String PERFORM_FETCH = "performFetch";

    //Instance API
    private static final String INSTANCE_ADD_TAG = "instance_add_tag";
    private static final String INSTANCE_REMOVE_TAG = "instance_remove_tag";
    private static final String INSTANCE_CONTAINS_TAG = "instance_contains_tag";
    private static final String INSTANCE_GET_VALUE_FOR_TAG = "instance_get_value_for_tag";
    private static final String INSTANCE_GET_ALL_TAGS = "instance_get_all_tags";
    private static final String CURRENT_INSTANCE = "current_instance";

    //public static final String GET_REGION_STATE_FOR_PLACE_ID = "getRegionStateforPlaceId";

    //Event callbacks
    static final String DID_ENTER_RANGE = "enterBeacon";
    static final String DID_EXIT_RANGE = "exitBeacon";
    static final String BEACON_PROXIMITY_CHANGE = "beaconProximityChange";
    static final String DID_ENTER_PLACE = "enterPlace";
    static final String DID_EXIT_PLACE = "exitPlace";
    static final String DID_ENTER_ZONE = "enterZone";
    static final String DID_EXIT_ZONE = "exitZone";


    //Action callbacks
    static final String DISPLAY_ALERT = "displayAlert";
    static final String OPEN_URL = "openUrl";
    static final String SHOW_EMBEDDED_HTML = "showEmbeddedHtml";
    static final String PLAY_VIDEO_FROM_URL = "playVideo";
    static final String IMAGE_FROM_URL = "showImage";
    static final String PASSBOOK_FROM_URL = "addPassbook";
    static final String ADD_TAG = "addTag";
    static final String PLAY_NOTIFICATION_SOUND = "playSound";
    static final String PERFORM_CUSTOM_ACTION = "customAction";

    //Other callbacks
    static final String DID_LOADED_BEACONS_DATA = "didLoadedBeaconsData";

    //User API
    private static String USER_SET_CUSTOM_PROPERTY = "user_set_custom_property";
    private static final String USER_GET_CUSTOM_PROPERTY = "user_custom_property";
    private static final String USER_SAVE = "user_save";
    private static String IS_USER_LOGGED_IN = "is_user_logged_in";
    private static final String CURRENT_USER = "current_user";


    final static List<String> knownActions = Arrays.asList(
            SET_LOG_LEVEL,
            VERSION,
            APP_KEY,
            APP_SECRET,
            INIT,
            LOG_LEVEL,
            INSTANCE_SESSION,
            INSTANCE_IDENTIFIER,
            PROXIMITY_ENABLED,
            SET_PROXIMITY_ENABLED,
            INSTANCE_USER_LOGIN,
            INSTANCE_USER_LOGGED_IN,
            INSTANCE_USER_LOGOUT,
            INSTANCE_SET_CUSTOM_PROPERTY,
            INSTANCE_CUSTOM_PROPERTY,
            CUSTOM_PROPERTY,
            PLACES_INSIDE,
            SET_GEOTRACKING_ENABLED,
            PERFORM_FETCH,
            INSTANCE_ADD_TAG,
            INSTANCE_REMOVE_TAG,
            INSTANCE_CONTAINS_TAG,
            INSTANCE_GET_VALUE_FOR_TAG,
            INSTANCE_GET_ALL_TAGS,
            CURRENT_INSTANCE,
            USER_SET_CUSTOM_PROPERTY,
            USER_GET_CUSTOM_PROPERTY,
            USER_SAVE,
            IS_USER_LOGGED_IN,
            CURRENT_USER
    );

    final static List<String> knownCallbackActions = Arrays.asList(
            DID_ENTER_RANGE,
            DID_EXIT_RANGE,
            BEACON_PROXIMITY_CHANGE,
            DID_ENTER_PLACE,
            DID_EXIT_PLACE,
            DID_ENTER_ZONE,
            DID_EXIT_ZONE,
            DISPLAY_ALERT,
            OPEN_URL,
            SHOW_EMBEDDED_HTML,
            PLAY_VIDEO_FROM_URL,
            IMAGE_FROM_URL,
            PASSBOOK_FROM_URL,
            ADD_TAG,
            PLAY_NOTIFICATION_SOUND,
            PERFORM_CUSTOM_ACTION,
            DID_LOADED_BEACONS_DATA
    );

}
