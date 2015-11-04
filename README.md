MOCA SDK for PhoneGap
=====================

<img src="https://github.com/mocaplatform/moca-phonegap-sdk/blob/master/media/phonegap-ios-xl.png" width="800px">

What is MOCA SDK?
-----------------

The MOCA SDK for PhoneGap lets you turn you mobile app into a powerful marketing tool.
Effortlessly add iBeacon and geolocation driven proximity experiences to your PhoneGap app, engage your users and understand them with MOCA analytics.
The SDK enables you to quickly connect to [MOCA backend platform](http://mocaplatform.com), deploy beacon experiences from the cloud, and track your users.

MOCA PhoneGap SDK is a drop-in Cordova plugin that provides an easy way to integrate proximity experience services into your cross-platform PhoneGap apps. 

![MOCA SDK Framework Architecture](https://github.com/mocaplatform/moca-ios-sdk/blob/master/Assets/images/moca-proximity.png)


PLATFORM SUPPORT
----------------
This plugin supports PhoneGap/Cordova apps running on iOS and Android. Windows Phone plugin is under development.


VERSION REQUIREMENTS
---------------------
This plugin is meant to work with Cordova 3.4.0+ and the latest versions of the MOCA SDK libraries. 


GETTING STARTED
-----------------

## Developer documentation  

See documentation in docs/html folder.

### More information    

For information, please visit [http://mocaplatform.com](http://mocaplatform.com)


INSTALLATION
------------

Automatic installation using PhoneGap/Cordova CLI (iOS and Android)

1. For iOS, make sure you update your iOS project to Cordova iOS version 3.4.1 or newer before installing this plugin.

  ````
    cordova platform update ios
  ````
  
2. For Android, make sure the Android SDK is up to date. Google Play Service 6.1+ are required.

  ````
    cordova platform update android
  ````
   
3. Install this plugin using PhoneGap/Cordova cli:

   ````
    cordova plugin add https://github.com/innoquant/moca-phonegap.git#:/MOCASDK
   ````
   
4. Modify the config.xml directory to contain (replacing with your configuration settings):
   
   ````
   <!-- MOCA SDK credentials -->
   <preference name="moca_app_key" value="YOUR_APP_KEY" />
   <preference name="moca_app_secret" value="YOUR-APP-SECRET" />
   <preference name="gcm_sender" value="\ YOUR-GCM-SENDER-ID" />

   ````
  `GCM-SENDER-ID` is required only if you are planning to use MOCA Remote Push Notifications in Android. This won't affect the behavior of the proximity experiences.

5. You may want to modify the message shown to the user when prompting for location permission. In order to do so, edit the `YourAppName-Info.plist` file and key `NSLocationAlwaysUsageDescription` entry.
 
BASIC EXAMPLES
--------------

The JavaScript API follows an asynchronous callback approach with hooks for events such as Enter Beacon Range, Enter Place or Display Notification Alert event. Below is a brief example of this API in use:

````
// Register for any MOCA events
document.addEventListener("moca.enterbeacon", function (beacon) {
   console.log("Did enter beacon with ID: " + beacon.identifier + ", name: " + beacon.name);
})

document.addEventListener("moca.enterplace", function (place) {
    console.log("Did enter place: " + place.name);
})

document.addEventListener("moca.dataready", function (event) {
    console.log("MOCA beacons & campagins are ready");
})

// Alternative method to register MOCA event listeners
MOCA.addEnterZoneListener(function (zone) {
    console.log("Did enter zone " + zone.identifier);
})
````

JavaScript API Usage
--------------------

Print MOCA SDK version:
````
  MOCA.version (function (version) {
      // ...
  });
````

Get MOCA app key:
````
  MOCA.appKey (function (key) {
     // ...
  });
````

Check if MOCA was initialized:
````
  if (MOCA.initialized(function (isInited)) {
      if (isInited) {
         // ...
      } else {
         // ...
      }
  }
````

Check if MOCA proximity is enabled:
````
  if (MOCA.proximityEnabled(function (enabled)) {
      if (enabled) {
         // ...
      } else {
         // ...
      }
  }
````

Enable MOCA proximity:
````
  MOCA.setProximityEnabled(true, function () {
      // ...
  });
````

Get log level:
````
  MOCA.getLogLevel (function (level) {
      // ...
  });      
````

Set log level:
````
  // var level = "info" | "debug" | "trace" | "warning" | "error" | "off"
  MOCA.setLogLevel (level, function () {
      // ...
  });      
````

Login user:
````
  MOCA.login (userId, function () {
      // ...
  });      
````

Logout current user:
````
  MOCA.logout (function () {
      // ...
  });      
````

Check if user has been logged in::
````
  MOCA.userLoggedIn (function (isLoggedIn) {
      if (isLoggedIn) {
         // ...
      } else {
         // ...
      }
  });      
````

Perform asynchronous fetch of beacons/campaigns data from cloud:
````
  MOCA.performFetch (function () {
      // ...
  });      
````

Get custom property by key:
````
  MOCA.customProperty (key, function (key, value) {
      // ...
  });      
````

Set custom property (key/value):
````
  MOCA.setCustomProperty (key, value, function () {
      // ...
  });      
````

Get MOCA instance unique ID:
````
  MOCAInstance.identifier (function (iid) {
      // ...
  });      
````

Get app session number:
````
  MOCAInstance.session (function (sessionNumber) {
      // ...
  });      
````

Get device push token:
````
  MOCAInstance.deviceToken (function (token) {
      // ...
  });      
````

JavaScript Trigger Events
-------------------------

Handle MOCA data ready event:
````
  MOCA.addDataReadyListener (function (e) {
     // e.detail.beacons -- array of beacon objects. each beacon has identifier, name and code.
  }); 
````
This method invoked when a proximity service loaded or updated a registry of beacons from MOCA cloud or from local cache.

Handle enter beacon range event:
````
  MOCA.addEnterBeaconListener (function (e) {
     // e.detail.identifier -- beacon id
     // e.detail.name -- beacon name
     // e.detail.code -- beacon code, optional
     // e.detail.proximity -- numeric proximity code (unkown=0, immediate=1, near=2, far=3)  
  }); 
````

Handle exit beacon range event:
````
  MOCA.addExitBeaconListener (function (e) {
     // e.detail.identifier -- beacon id
     // e.detail.name -- beacon name
  }); 
````

Method triggered when the state of a beacon proximity did changed:
````
  MOCA.addBeaconProximityChangeListener (function (e) {
    // e.detail.identifier -- beacon id
    // e.detail.prevProximity -- previous beacon proximity state (unkown=0, immediate=1, near=2, far=3)  
    // e.detail.curProximity -- current beacon proximity state (unkown=0, immediate=1, near=2, far=3) 
  }); 
````

Handle enter place event:
````
  MOCA.addEnterPlaceListener (function (e) {
     // e.detail.identifier -- place id
     // e.detail.name -- place name
  }); 
````

Handle exit place event:
````
  MOCA.addExitPlaceListener (function (e) {
     // e.detail.identifier -- place id
     // e.detail.name -- place name
  }); 
````

Handle enter zone event:
````
  MOCA.addEnterZoneListener (function (e) {
     // e.detail.identifier -- zone id
     // e.detail.name -- zone name
     // e.detail.placeId -- place identifier this zone belongs to
     // e.detail.floorNumber -- zone floorNumber, optional
     // e.detail.shortId -- zone shortId, optional
  }); 
````

Handle exit zone event:
````
  MOCA.addExitZoneListener (function (e) {
     // e.detail.identifier -- zone id
     // e.detail.name -- zone name
     // e.detail.placeId -- place identifier this zone belongs to
     // e.detail.floorNumber -- zone floorNumber, optional
     // e.detail.shortId -- zone shortId, optional
  }); 
````

JavaScript Action Events
-------------------------

Handle custom action event:
````
  MOCA.addCustomActionListener (function (e) {
    // e.detail.customAttribute - custom action attribute provided by MOCA   
  );
````


CHANGELOG
-----------

v1.6.9
- Support for MOCA iOS SDK v1.6.8 and Android v1.6.2.
- Removed Google Play Services as a plugin (Android), added as a gradle dependency.

v1.6.0
- MOCA iOS SDK 1.6.3
- MOCA Android SDK 1.6.0
- MOCA.js with JavaScript MOCA event callbacks

v1.5.0
- MOCA iOS SDK 1.5.2
- MOCA Android SDK 1.5.0
- Segmentation
- Improved analytics
- Offline HTML campaigns
- PassBook support for iOS/Android
- Extended JavaScript API support (start/stop proximity service)

v1.3.1
- Push notification service disabled by default
- Support for PassBook cards in Android with PassWallet app


v1.3.0
This release provides support for both iOS and Android
- Support for MOCA SDK for iOS from v1.3.9
- Support for MOCA SDK for Android from v1.3.0

v1.0.0
First release
- Support for MOCA SDK for iOS from v1.3.9


LICENSE
-----------

See LICENSE.md file for licensing information and credits.
