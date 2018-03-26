//
//  MOCAPluginActionConstants.h
//  HelloCordova
//
//  Created by David Gonzalez Shannon on 17/12/15.
//
//

#ifndef MOCAPluginConstants_h
#define MOCAPluginConstants_h


#endif /* MOCAPluginConstants_h */


#define DID_ENTER_RANGE @"enterBeacon"
#define DID_EXIT_RANGE @"exitBeacon"
#define BEACON_PROXIMITY_CHANGE @"beaconProximityChange"
#define DID_ENTER_PLACE @"enterPlace"
#define DID_EXIT_PLACE @"exitPlace"
#define DID_ENTER_ZONE @"enterZone"
#define DID_EXIT_ZONE @"exitZone"


//Action callbacks
#define DISPLAY_ALERT @"displayAlert"
#define OPEN_URL @"openUrl"
#define SHOW_EMBEDDED_HTML @"showEmbeddedHtml"
#define PLAY_VIDEO_FROM_URL @"playVideo"
#define IMAGE_FROM_URL @"showImage"
#define PASSBOOK_FROM_URL @"addPassbook"
#define ADD_TAG @"addTag"
#define PLAY_NOTIFICATION_SOUND @"playSound"
#define PERFORM_CUSTOM_ACTION @"customAction"

//Other callbacks
#define DID_LOADED_BEACONS_DATA @"didLoadedBeaconsData"

//Other constants
#define APP_KEY @"moca_app_key"
#define APP_SECRET @"moca_app_secret"


#define GCM_SENDER_ID @"gcm_sender_id"