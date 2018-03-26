//  v2.5.0
//
//  MOCA PhoneGap JavaScript Plugin
//
//  This module is part of InnoQuant MOCA Platform.
//
//  Copyright (c) 2015 InnoQuant Strategic Analytics, S.L.
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
var MOCA = function() {
    // CONSTANTS
    // Events
    this.DID_ENTER_RANGE = "enterBeacon";
    this.DID_EXIT_RANGE = "exitBeacon";
    this.BEACON_PROXIMITY_CHANGE = "beaconProximityChange";
    this.DID_ENTER_PLACE = "enterPlace";
    this.DID_EXIT_PLACE = "exitPlace";
    this.DID_ENTER_ZONE = "enterZone";
    this.DID_EXIT_ZONE = "exitZone";
    // Actions
    this.DISPLAY_ALERT = "displayAlert";
    this.OPEN_URL = "openUrl";
    this.SHOW_EMBEDDED_HTML = "showEmbeddedHtml";
    this.PLAY_VIDEO_FROM_URL = "playVideo";
    this.IMAGE_FROM_URL = "showImage";
    this.PASSBOOK_FROM_URL = "addPassbook";
    this.ADD_TAG = "addTag";
    this.PLAY_NOTIFICATION_SOUND = "playSound";
    this.PERFORM_CUSTOM_ACTION = "customAction";
    // Other
    this.DID_LOADED_BEACONS_DATA = "didLoadedBeaconsData";
    this.APP_KEY = "moca_app_key";
    this.APP_SECRET = "moca_app_secret";
    this.GCM_SENDER_ID = "gcm_sender_id";
};
// Types
MOCA.prototype.logLevel = {
    Off: 0,
    Error: 1,
    Warning: 2,
    Info: 3,
    Debug: 4,
    Trace: 5
};
MOCA.prototype.fetchStatus = {
    NoData: 0,
    NewData: 1
};
// Helpers
MOCA.prototype.failure = function(msg) {
    console.log("MOCA: Javascript Callback Error: " + msg);
};
MOCA.prototype.call_native = function(callback, name, args) {
    // arguments is not a real Array, so first lets convert it.
    var methodArgs = (arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments));
    var nativeArgs = [];
    if (methodArgs.length == 3) {
        nativeArgs = [methodArgs[2]];
    } else if (arguments.length > 3) {
        nativeArgs = methodArgs.slice(2, methodArgs.length);
    }
    ret = cordova.exec(callback, // called when signature capture is successful
        this.failure, // called when signature capture encounters an error
        'MOCAPlugin', // Tell cordova that we want to run "MOCAPlugin"
        name, // Tell the plugin the action we want to perform
        nativeArgs // List of arguments to the plugin
    );
    return ret;
};
MOCA.prototype.isPlatformIOS = function() {
    return device.platform == "iPhone" || device.platform == "iPad" || device.platform == "iPod touch" || device.platform == "iOS";
};
// --- MOCA API ------
// Logging
MOCA.prototype.setLogLevel = function(logLevel, callback) {
    this.call_native(callback, "setLogLevel", logLevel);
};
// Getters
MOCA.prototype.version = function(callback) {
    this.call_native(callback, "version");
};
MOCA.prototype.appKey = function(callback) {
    this.call_native(callback, "appKey");
};
MOCA.prototype.appSecret = function(callback) {
    this.call_native(callback, "appSecret");
};
MOCA.prototype.initialized = function(callback) {
    this.call_native(callback, "initialized");
};
MOCA.prototype.pushEnabled = function(callback) {
    return MOCA.call_native(callback, "instance_pushEnabled");
};
MOCA.prototype.logLevel = function(callback) {
    this.call_native(callback, "logLevel");
};
// On/Off Proximity Service
MOCA.prototype.proximityEnabled = function(callback) {
    this.call_native(callback, "proximityEnabled");
};
MOCA.prototype.setProximityEnabled = function(enabled, callback) {
    this.call_native(callback, "setProximityEnabled", enabled);
};
MOCA.prototype.setGeoTrackingEnabled = function(enabled, callback) {
    this.call_native(callback, "setGeoTrackingEnabled", enabled);
};
// Login/Logout
MOCA.prototype.login = function(userId, callback) {
    this.call_native(callback, "instance_userLogin", userId);
};
MOCA.prototype.userLoggedIn = function(callback) {
    this.call_native(callback, "instance_userLoggedIn");
};
MOCA.prototype.logout = function(callback) {
    this.call_native(callback, "instance_userLogout");
};
// Background Fetch
MOCA.prototype.performFetch = function(callback) {
    this.call_native(callback, "performFetch");
};
MOCA.prototype.placesInside = function(callback) {
    this.call_native(callback, "placesInside");
};

// Custom properties

MOCA.prototype.setCustomProperty = function(key, value, callback) {
    console.warn("MOCA.setCustomProperty has been deprecated since API 2.5.0, use MOCA.currentInstance().setCustomProperty(key, value, callback) instead");
    this.call_native(callback, "instance_setCustomProperty", key, value);
};
MOCA.prototype.customProperty = function(key, callback) {
    console.warn("MOCA.customProperty has been deprecated since API 2.5.0, use MOCA.currentInstance().customProperty() instead");
    this.call_native(callback, "instance_customProperty");
};
// ----------------------------------------
// MOCA Events
// ----------------------------------------
//
// Handle enter beacon range event
//
// MOCA.addEnterBeaconListener (function (e) {
//     // e.identifier // beacon id
//     // e.name // beacon name
//     // e.code // beacon code, optional
//     // e.proximity // numeric proximity code (unknown=0, immediate=1, near=2, far=3)
// });
//
MOCA.prototype.addEnterBeaconListener = function(callback) {
    this.call_native(callback, "enterBeacon");
};
//
// Handle exit beacon range event
//
// MOCA.addExitBeaconListener (function (e) {
//     // e.identifier // beacon id
//     // e.name // beacon name
// });
//
MOCA.prototype.addExitBeaconListener = function(callback) {
    this.call_native(callback, "exitBeacon");
};
//
// Method triggered when the state of a beacon proximity did changed.
//
// MOCA.addBeaconProximityChangeListener (function (e) {
//     // e.identifier // beacon id
//     // e.prevProximity // previous beacon proximity state (unkown=0, immediate=1, near=2, far=3)
//     // e.curProximity // current beacon proximity state (unkown=0, immediate=1, near=2, far=3)
// });
//
MOCA.prototype.addBeaconProximityChangeListener = function(callback) {
    this.call_native(callback, "beaconProximityChange");
};
//
// Method triggered when the device did entered a place.
//
// MOCA.addEnterPlaceListener (function (e) {
//     // e.identifier // place id
//     // e.name // place name
// });
//
MOCA.prototype.addEnterPlaceListener = function(callback) {
    this.call_native(callback, "enterPlace");
};
//
// Method triggered when the device did exited a place.
//
// MOCA.addExitPlaceListener (function (e) {
//     // e.identifier // place id
//     // e.name // place name
// });
//
MOCA.prototype.addExitPlaceListener = function(callback) {
    this.call_native(callback, "exitPlace");
};
//
// Method triggered when the device did entered a zone.
//
// MOCA.addEnterZoneListener (function (e) {
//     // e.identifier // zone id
//     // e.name // zone name
//     // e.placeId // place identifier this zone belongs to
//     // e.floorNumber // zone floorNumber, optional
//     // e.shortId // zone shortId, optional
// });
//
MOCA.prototype.addEnterZoneListener = function(callback) {
    this.call_native(callback, "enterZone");
};
//
// Method triggered when the device did exited a place.
//
// MOCA.addExitZoneListener (function (e) {
//     // e.identifier // zone id
//     // e.name // zone name
//     // e.placeId // place identifier this zone belongs to
//     // e.floorNumber // zone floorNumber, optional
//     // e.shortId // zone shortId, optional
// });
//
MOCA.prototype.addExitZoneListener = function(callback) {
    this.call_native(callback, "exitZone");
};
//
// Method invoked when a proximity service loaded or updated a registry of beacons
// from MOCA cloud or from local cache.
//
// MOCA.addDataReadyListener (function (e) {
//     // e.beacons // array of beacon objects. each beacon has identifier, name and code.
// });
//
MOCA.prototype.addDataReadyListener = function(callback) {
    this.call_native(callback, "didLoadedBeaconsData");
};
// ----------------------------------------
// MOCA Action Callbacks
// ----------------------------------------
// Action Object:
// {
//   "detail": {
//     "action_name": "action_message"
//   }
// }
//
// Method invoked when a custom action is invoked.
//
// MOCA.addCustomActionListener (function (e) {
//     // e.detail
// });
//
MOCA.prototype.addCustomActionListener = function(callback) {
    this.call_native(callback, "customAction");
};
//
// Method invoked when a message action is invoked.
//
// args: (false, callback) to allow MOCA to show the experience.
//       (true, callback) to prevent MOCA from showing the experience. (No message will be shown)
//
// MOCA.addDisplayAlertListener (false, function (e) {
//     // e.detail.displayAlert // String with Message to show
// });
//
MOCA.prototype.addDisplayAlertListener = function(args, callback) {
    this.call_native(callback, "displayAlert", args);
};
//
// Method invoked when an "open url" action is invoked.
//
// args: (false, callback) to allow MOCA to show the experience.
//       (true, callback) to prevent MOCA from showing the experience. (No webview will be shown)
//
// MOCA.addOpenUrlListener (false, function (e) {
//     // e.detail.openUrl // String with URL
// });
//
MOCA.prototype.addOpenUrlListener = function(args, callback) {
    this.call_native(callback, "openUrl", args);
};
//
// Method invoked when an embedded html action is invoked.
//
//
// args: (false, callback) to allow MOCA to show the experience.
//       (true, callback) to prevent MOCA from showing the experience. (No webview will be shown)
//
// MOCA.addShowEmbeddedHtmlListener (false, function (e) {
//     // e.detail.showEmbeddedHtml // String with embedded HTML
// });
//
MOCA.prototype.addShowEmbeddedHtmlListener = function(args, callback) {
    this.call_native(callback, "showEmbeddedHtml", args);
};
//
// Method invoked when a video action is invoked.
//
//
// args: (false, callback) to allow MOCA to show the experience.
//       (true, callback) to prevent MOCA from showing the experience. (No video will be played)
//
// MOCA.addPlayVideoListener (false, function (e) {
//     // e.detail.playVideo // String with video URL
// });
//
MOCA.prototype.addPlayVideoListener = function(args, callback) {
    this.call_native(callback, "playVideo", args);
};
//
// Method invoked when a image action is invoked.
//
//
// args: (false, callback) to allow MOCA to show the experience.
//       (true, callback) to prevent MOCA from showing the experience. (No image will be shown)
//
// MOCA.addShowImageListener (false, function (e) {
//     // e.detail.showImage // String with Image URL
// });
//
MOCA.prototype.addShowImageListener = function(args, callback) {
    this.call_native(callback, "showImage", args);
};
//
// Method invoked when a passbook action is invoked.
//
//
// args: (false, callback) to allow MOCA to show the experience.
//       (true, callback) to prevent MOCA from showing the experience. (No passbook will be shown)
//
// MOCA.addAddPassbookListener (false, function (e) {
//     // e.detail.addPassbook // String with Passbook URL
// });
//
MOCA.prototype.addAddPassbookListener = function(args, callback) {
    this.call_native(callback, "addPassbook", args);
};
//
// Method invoked when a tag action is invoked.
//
// MOCA.addAddTagListener (function (e) {
//     // e.detail.addTag // JSONObject with tagName and tagValue
// });
//
MOCA.prototype.addAddTagListener = function(callback) {
    this.call_native(callback, "addTag");
};
//
// Method invoked when a sound action is invoked.
//
//
// args: (false, callback) to allow MOCA to show the experience.
//       (true, callback) to prevent MOCA from showing the experience. (No sound will be played)
//
// MOCA.addPlaySoundListener (false, function (e) {
//     // e.detail.playSound // String with sound path
//});
//
MOCA.prototype.addPlaySoundListener = function(args, callback) {
    this.call_native(callback, "playSound", args);
};

var MOCAPlugin = new MOCA();
var MOCAUser = function() {};

MOCAUser.prototype.setCustomProperty = function(key, value, callback) {
   return MOCAPlugin.call_native(callback, "user_set_custom_property", key, value);
};
MOCAUser.prototype.setCustomProperty = function(key, value, callback) {
    return MOCAPlugin.call_native(callback, "user_set_custom_property", key, value);
};
MOCAUser.prototype.customProperty = function(key, callback) {
    return MOCAPlugin.call_native(callback, "user_custom_property", key);
};
MOCAUser.prototype.save = function(callback) {
    return MOCAPlugin.call_native(callback, "user_save");
};
MOCAUser.prototype.id = function(callback) {
    return this._id;
};


// Global exports
var MOCAInstance = function(){};

MOCAInstance.prototype.setCustomProperty = function(key, value, callback) {
    return MOCAPlugin.call_native(callback, "instance_setCustomProperty", key, value);
};
MOCAInstance.prototype.customProperty = function(key, callback) {
    return MOCAPlugin.call_native(callback, "instance_customProperty");
};
MOCAInstance.prototype.identifier = function(callback) {
    console.warn("Calling a deprecated method 'instance.identifier(callback)', use 'instance.id' instead")
    callback(this["id"]);
};
MOCAInstance.prototype.deviceToken = function(callback) {
    return MOCAPlugin.call_native(callback, "instance_deviceToken");
};
MOCAInstance.session = function(callback) {
    return MOCAPlugin.call_native(callback, "instance_session");
};
MOCAInstance.prototype.birthDay = function(callback) {
    return MOCAPlugin.call_native(callback, "instance_birthDay");
};
//TAG API
MOCAInstance.prototype.addTag = function(tagName, tagValue, callback) {
    return MOCAPlugin.call_native(callback, "instance_add_tag", tagName, tagValue);
};
MOCAInstance.prototype.removeTag = function(tagName, callback) {
    return MOCAPlugin.call_native(callback, "instance_remove_tag", tagName);
};
MOCAInstance.prototype.containsTag = function(tagName, callback) {
    return MOCAPlugin.call_native(callback, "instance_contains_tag", tagName);
};
MOCAInstance.prototype.getTagValue = function(tagName, callback) {
    return MOCAPlugin.call_native(callback, "instance_get_value_for_tag", tagName);
};
MOCAInstance.prototype.currentUser = function(callback) {
    let isUserLoggedIn = MOCAPlugin.call_native(
        function(isUserLoggedIn) {
          if (isUserLoggedIn) {
            var user = new MOCAUser();
            MOCAPlugin.call_native(function(props) {
              if (props != null && props !== undefined && props.length != 0) {
                for (var key in props) {
                  if(key === "_id") {
                    user["id"] = props[key];
                  } else {
                    user[key] = props[key];
                  }
                }
                callback(user);
              } else {
                callback(null, "No user is logged in");
              }
            }, "current_user");
          }
        },
        "is_user_logged_in");
}


//load MOCAInstance at startup
var instance = new MOCAInstance();

MOCAPlugin.call_native(function(props) {
  if (props != null && props !== undefined && props.length != 0) {
    for (var key in props) {
      if(key === "instance_id") {
        instance["id"] = props[key];
      }
      instance[key] = props[key];
    }
  } else {
    console.error("No instance props. Is MOCA SDK Running?");
  }
}, "current_instance");

// MOCA Instance
MOCA.prototype.currentInstance = function() {
    return instance;
};


module.exports = MOCAPlugin;