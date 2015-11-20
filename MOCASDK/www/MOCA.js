//  MOCA.js
//  v2.0.0
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

var MOCA = function () {

};

var MOCAInstance = function () {

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

MOCA.prototype.failure = function (msg) {
    console.log("MOCA: Javascript Callback Error: " + msg);
};


MOCA.prototype.call_native = function (callback, name, args) {
    if (arguments.length == 2) {
        args = [];
    }
    ret = cordova.exec(
    callback, // called when signature capture is successful
    this.failure, // called when signature capture encounters an error
    'MOCAPlugin', // Tell cordova that we want to run "MOCAPlugin"
    name, // Tell the plugin the action we want to perform
    args // List of arguments to the plugin
    );
    return ret;
};

MOCA.prototype.isPlatformIOS = function () {
    return device.platform == "iPhone" || device.platform == "iPad" || device.platform == "iPod touch" || device.platform == "iOS";
};

// --- MOCA API ------

// Logging

MOCA.prototype.setLogLevel = function (logLevel, callback) {
    this.call_native(callback, "setLogLevel", [logLevel]);
};

// Getters

MOCA.prototype.version = function (callback) {
    this.call_native(callback, "version");
};

MOCA.prototype.appKey = function (callback) {
    this.call_native(callback, "appKey");
};

MOCA.prototype.appSecret = function (callback) {
    this.call_native(callback, "appSecret");
};

MOCA.prototype.initialized = function (callback) {
    this.call_native(callback, "initialized");
};

MOCA.prototype.logLevel = function (callback) {
    this.call_native(callback, "logLevel");
};

// On/Off Proximity Service
MOCA.prototype.proximityEnabled = function (callback) {
    this.call_native(callback, "proximityEnabled");
};

MOCA.prototype.setProximityEnabled = function (enabled, callback) {
    this.call_native(callback, "setProximityEnabled", [enabled]);
};

// Login/Logout
MOCA.prototype.login = function (userId, callback) {
    this.call_native(callback, "instance_userLogin", [userId]);
};

MOCA.prototype.userLoggedIn = function (callback) {
    this.call_native(callback, "instance_userLoggedIn");
};

MOCA.prototype.logout = function (callback) {
    this.call_native(callback, "instance_userLogout");
};

// Background Fetch

MOCA.prototype.performFetch = function (callback) {
    this.call_native(callback, "performFetch");
};

//getRegionState for placeid

MOCA.prototype.getRegionStateforPlaceId = function (placeId, callback) {
    this.call_native(callback, "getRegionStateforPlaceId", [placeId]);
};

// MOCA Instance

MOCA.prototype.currentInstance = MOCAInstance;

// Custom properties
MOCA.prototype.setCustomProperty = function (key, value, callback) {
    this.call_native(callback, "instance_setCustomProperty", [key, value]);
};

MOCA.prototype.customProperty = function (key, callback) {
    this.call_native(callback, "instance_customProperty");
};

MOCAInstance.prototype.identifier = function (callback) {
    this.call_native(callback, "instance_identifier");
};

MOCAInstance.prototype.deviceToken = function (callback) {
    this.call_native(callback, "instance_deviceToken");
};

MOCAInstance.prototype.session = function (callback) {
    this.call_native(callback, "instance_session");
};

MOCAInstance.prototype.birthDay = function (callback) {
    this.call_native(callback, "instance_birthDay");
};

MOCAInstance.prototype.pushEnabled = function (callback) {
    this.call_native(callback, "instance_pushEnabled");
};



// ----------------------------------------
// MOCA Events
// ----------------------------------------

//
// Handle enter beacon range event
//
// MOCA.addEnterBeaconListener (function (e) {
//     // e.identifier -- beacon id
//     // e.name -- beacon name
//     // e.code -- beacon code, optional
//     // e.proximity -- numeric proximity code (unknown=0, immediate=1, near=2, far=3)
// });
//
MOCA.prototype.addEnterBeaconListener = function (callback) {
    this.call_native(callback, "enterBeacon");
};

//
// Handle exit beacon range event
//
// MOCA.addExitBeaconListener (function (e) {
//     // e.identifier -- beacon id
//     // e.name -- beacon name
// });
//
MOCA.prototype.addExitBeaconListener = function (callback) {
    this.call_native(callback, "exitBeacon");
};


//
// Method triggered when the state of a beacon proximity did changed.
//
// MOCA.addBeaconProximityChangeListener (function (e) {
//     // e.identifier -- beacon id
//     // e.prevProximity -- previous beacon proximity state (unkown=0, immediate=1, near=2, far=3)
//     // e.curProximity -- current beacon proximity state (unkown=0, immediate=1, near=2, far=3)
// });
//
MOCA.prototype.addBeaconProximityChangeListener = function (callback) {
    this.call_native(callback, "beaconProximityChange");
};

//
// Method triggered when the device did entered a place.
//
// MOCA.addEnterPlaceListener (function (e) {
//     // e.identifier -- place id
//     // e.name -- place name
// });
//
MOCA.prototype.addEnterPlaceListener = function (callback) {
    this.call_native(callback, "enterPlace");
};

//
// Method triggered when the device did exited a place.
//
// MOCA.addExitPlaceListener (function (e) {
//     // e.identifier -- place id
//     // e.name -- place name
// });
//
MOCA.prototype.addExitPlaceListener = function (callback) {
    this.call_native(callback, "exitPlace");
};

//
// Method triggered when the device did entered a zone.
//
// MOCA.addEnterZoneListener (function (e) {
//     // e.identifier -- zone id
//     // e.name -- zone name
//     // e.placeId -- place identifier this zone belongs to
//     // e.floorNumber -- zone floorNumber, optional
//     // e.shortId -- zone shortId, optional
// });
//
MOCA.prototype.addEnterZoneListener = function (callback) {
    this.call_native(callback, "enterZone");
};

//
// Method triggered when the device did exited a place.
//
// MOCA.addExitZoneListener (function (e) {
//     // e.identifier -- zone id
//     // e.name -- zone name
//     // e.placeId -- place identifier this zone belongs to
//     // e.floorNumber -- zone floorNumber, optional
//     // e.shortId -- zone shortId, optional
// });
//
MOCA.prototype.addExitZoneListener = function (callback) {
    this.call_native(callback, "exitZone");
};

//
// Method invoked when a proximity service loaded or updated a registry of beacons
// from MOCA cloud or from local cache.
//
// MOCA.addDataReadyListener (function (e) {
//     // e.beacons -- array of beacon objects. each beacon has identifier, name and code.
// });
//
MOCA.prototype.addDataReadyListener = function (callback) {
    this.call_native(callback, "didLoadedBeaconsData");
};

//
// Method invoked when a custom action is invoked.
//
// MOCA.addCustomActionListener (function (e) {
//     // e.customAttribute -- custom action attribute provided by MOCA
// });
//
MOCA.prototype.addCustomActionListener = function (callback) {
    this.call_native(callback, "customAction");
};

//
// Method invoked when a custom action is invoked.
//
// MOCA.addDisplayAlertListener (function (e) {
//     // e.customAttribute -- custom action attribute provided by MOCA
// });
//
MOCA.prototype.addDisplayAlertListener = function (callback) {
    this.call_native(callback, "displayAlert");
};

//
// Method invoked when a custom action is invoked.
//
// MOCA.addOpenUrlListener (function (e) {
//     // e.customAttribute -- custom action attribute provided by MOCA
// });
//
MOCA.prototype.addOpenUrlListener = function (callback) {
    this.call_native(callback, "openUrl");
};

//
// Method invoked when a custom action is invoked.
//
// MOCA.addCustomActionListener (function (e) {
//     // e.customAttribute -- custom action attribute provided by MOCA
// });
//
MOCA.prototype.addShowEmbeddedHtmlListener = function (callback) {
    this.call_native(callback, "showEmbeddedHtml");
};

//
// Method invoked when a custom action is invoked.
//
// MOCA.addPlayVideoListener (function (e) {
//     // e.customAttribute -- custom action attribute provided by MOCA
// });
//
MOCA.prototype.addPlayVideoListener = function (callback) {
    this.call_native(callback, "playVideo");
};

//
// Method invoked when a custom action is invoked.
//
// MOCA.addShowImageListener (function (e) {
//     // e.customAttribute -- custom action attribute provided by MOCA
// });
//
MOCA.prototype.addShowImageListener = function (callback) {
    this.call_native(callback, "showImage");
};

//
// Method invoked when a custom action is invoked.
//
// MOCA.addAddPassbookListener (function (e) {
//     // e.customAttribute -- custom action attribute provided by MOCA
// });
//
MOCA.prototype.addAddPassbookListener = function (callback) {
    this.call_native(callback, "addPassbook");
};

//
// Method invoked when a custom action is invoked.
//
// MOCA.addAddTagListener (function (e) {
//     // e.customAttribute -- custom action attribute provided by MOCA
// });
//
MOCA.prototype.addAddTagListener = function (callback) {
    this.call_native(callback, "addTag");
};

//
// Method invoked when a custom action is invoked.
//
// MOCA.addPlaySoundListener (function (e) {
//     // e.customAttribute -- custom action attribute provided by MOCA
// });
//
MOCA.prototype.addPlaySoundListener = function (callback) {
    this.call_native(callback, "playSound");
};



// Global exports
module.exports = new MOCA();