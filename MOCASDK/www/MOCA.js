//
//  MOCA.js
//  v1.6.9
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

}

var MOCAInstance = function () {

}

// Types

MOCA.prototype.logLevel = {
  Off: 0,
  Error: 1,
  Warning: 2,
  Info: 3,
  Debug: 4,
  Trace: 5
}

MOCA.prototype.fetchStatus = {
  NoData: 0,
  NewData: 1
}

// Helpers

MOCA.prototype.failure = function (msg) {
  console.log("MOCA: Javascript Callback Error: " + msg)
}


MOCA.prototype.call_native = function (callback, name, args) {
  if(arguments.length == 2) {
    args = []
  }
  ret = cordova.exec(
      callback, // called when signature capture is successful
      this.failure, // called when signature capture encounters an error
      'MOCAPlugin', // Tell cordova that we want to run "MOCAPlugin"
      name, // Tell the plugin the action we want to perform
      args  // List of arguments to the plugin
  ); 
  return ret;
}

MOCA.prototype.isPlatformIOS = function () {
  return device.platform == "iPhone" || device.platform == "iPad" || device.platform == "iPod touch" || device.platform == "iOS"
}

// --- MOCA API ------

// Logging

MOCA.prototype.setLogLevel = function (logLevel, callback) {
  this.call_native(callback, "setLogLevel", [logLevel])
}

// Getters

MOCA.prototype.version = function (callback) {
  this.call_native(callback, "version");
}

MOCA.prototype.appKey = function (callback) {
  this.call_native(callback, "appKey");
}

MOCA.prototype.appSecret = function (callback) {
  this.call_native(callback, "appSecret")
}

MOCA.prototype.initialized = function (callback) {
  this.call_native(callback, "initialized")
}

MOCA.prototype.logLevel = function (callback) {
  this.call_native(callback, "logLevel")
}

// On/Off Proximity Service
MOCA.prototype.proximityEnabled = function (callback) {
  this.call_native(callback, "proximityEnabled")
}

MOCA.prototype.setProximityEnabled = function (enabled, callback) {
  this.call_native(callback, "setProximityEnabled", [enabled])
}

// Login/Logout
MOCA.prototype.login = function(userId, callback) {
  this.call_native(callback, "instance_userLogin", [userId]); 
}

MOCA.prototype.userLoggedIn = function(callback) {
  this.call_native(callback, "instance_userLoggedIn"); 
}

MOCA.prototype.logout = function(callback) {
  this.call_native(callback, "instance_userLogout"); 
}

// Background Fetch

MOCA.prototype.performFetch = function (callback) {
  this.call_native(callback, "performFetch")
}


// MOCA Instance

MOCA.prototype.currentInstance = MOCAInstance;
  
// Custom properties
MOCA.prototype.setCustomProperty = function (key, value, callback) {
  this.call_native(callback, "instance_setCustomProperty", [key, value]);
}

MOCA.prototype.customProperty = function (key, callback) {
  this.call_native(callback, "instance_customProperty");
}

MOCAInstance.prototype.identifier = function (callback) {
  this.call_native(callback, "instance_identifier");
}

MOCAInstance.prototype.deviceToken = function (callback) {
  this.call_native(callback, "instance_deviceToken");
}

MOCAInstance.prototype.session = function (callback) {
  this.call_native(callback, "instance_session");
}

MOCAInstance.prototype.birthDay = function (callback) {
  this.call_native(callback, "instance_birthDay");
}

MOCAInstance.prototype.pushEnabled = function (callback) {
  this.call_native(callback, "instance_pushEnabled");
}

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
//     // e.proximity -- numeric proximity code (unkown=0, immediate=1, near=2, far=3)  
// });  
//
MOCA.prototype.addEnterBeaconListener = function (callback) {
  document.addEventListener ("moca.enterbeacon", callback, false);
}

//
// Handle exit beacon range event
//
// MOCA.addExitBeaconListener (function (e) {
//     // e.identifier -- beacon id
//     // e.name -- beacon name
// });  
//
MOCA.prototype.addExitBeaconListener = function (callback) {
  document.addEventListener ("moca.exitbeacon", callback, false);
}


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
  document.addEventListener ("moca.beaconproximitychange", callback, false);
}

//
// Method triggered when the device did entered a place.
//
// MOCA.addEnterPlaceListener (function (e) {
//     // e.identifier -- place id
//     // e.name -- place name
// });  
//
MOCA.prototype.addEnterPlaceListener = function (callback) {
  document.addEventListener ("moca.enterplace", callback, false);
}

//
// Method triggered when the device did exited a place.
//
// MOCA.addEnterPlaceListener (function (e) {
//     // e.identifier -- place id
//     // e.name -- place name
// });  
//
MOCA.prototype.addExitPlaceListener = function (callback) {
  document.addEventListener ("moca.exitplace", callback, false);
}

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
  document.addEventListener ("moca.enterzone", callback, false);
}

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
  document.addEventListener ("moca.exitzone", callback, false);
}

//
// Method invoked when a proximity service loaded or updated a registry of beacons
// from MOCA cloud or from local cache.
//
// MOCA.addDataReadyListener (function (e) {
//     // e.beacons -- array of beacon objects. each beacon has identifier, name and code.
// });  
//
MOCA.prototype.addDataReadyListener = function (callback) {
  document.addEventListener ("moca.dataready", callback, false);
}

//
// Method invoked when a custom action is invoked.
//
// MOCA.addCustomActionListener (function (e) {
//     // e.customAttribute -- custom action attribute provided by MOCA   
// });  
//
MOCA.prototype.addCustomActionListener = function (callback) {
  document.addEventListener ("moca.customaction", callback, false);
}


// Global exports
module.exports = new MOCA();

