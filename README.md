MOCA SDK for PhoneGap
=====================

<img src="https://github.com/mocaplatform/moca-phonegap-sdk/blob/master/media/phonegap-ios-xl.png" width="800px">

What is MOCA SDK?
-----------------

The MOCA SDK for PhoneGap lets you turn you mobile app into a powerful marketing tool.
Effortlessly add iBeacon and geolocation driven proximity experiences to your Cordova / PhoneGap / IONIC app, engage your users and understand them with MOCA analytics.
The SDK enables you to quickly connect to [MOCA backend platform](http://mocaplatform.com), deploy beacon experiences from the cloud, and track your users.

MOCA PhoneGap SDK is a drop-in Cordova plugin that provides an easy way to integrate proximity experience services into your cross-platform hybrid apps. 

![MOCA SDK Framework Architecture](https://github.com/mocaplatform/moca-ios-sdk/blob/master/Assets/images/moca-proximity.png)

How to use it
-------------

For installation instructions and examples, please visit the [MOCA Developer portal](http://developer.mocaplatform.com/docs/installation).

Versioning
----------------
- This project uses [SemVer](http://semver.org/)

Release notes
-------------
###v2.4.3
- Latest Android SDK (2.3.2) that improves Wi-Fi Beacon behavior.

###v2.4.2
- Fixed integration with Latest Android SDK

###v2.4.1
- Latest iOS (2.2.1) and Android (2.3.2) Native SDKs.
- Unlimited number of geofences are now supported in both iOS and Android versions. 

###v2.3.3
- Added new `NSBluetoothPeripheralUsageDescription` mandatory key for iOS 10+ applications.

###v2.3.2
- Fixed an import issue in the Android implementation

###v2.3.1
- Added explicit background modes for the MOCA Plugin [iOS]

###v2.3.0
- Compatibility fix with latest versions of Cordova (iOS): Integration with native events in the AppDelegate is done via method swizzling.
- Latest Android library version.

###v2.2.2
- Fix: beacon proximity change callback is not called correctly on iOS.

###v2.2.0
- Support for MOCA iOS 1.9.6
- Support for Android SDK 1.9.1

###v2.1.0

- Support for MOCA iOS SDK 1.9.4
- Support for Android SDK 1.8.10 

###v2.0.1
Fixed a bug that prevented JavaScript calls from being called in the very first app launch.

###v1.7.0
- Support for Andrdoid SDK 1.8.0 and iOS 1.7.0

###v1.6.9
- Support for MOCA iOS SDK v1.6.8 and Android v1.6.2.
- Removed Google Play Services as a plugin (Android), added as a gradle dependency.

###v1.5.0
- Support for MOCA SDK for Android v1.5.0 (proximity start/stop functionality)

###v1.4.9
- Extended JavaScript API
- Support for MOCA SDK for iOS from v1.5.2
- Support for MOCA SDK for Android from v1.4.9
- Tested with Cordova 4.3

###v1.3.0
This release provides support for both iOS and Android
- Support for MOCA SDK for iOS from v1.3.9
- Support for MOCA SDK for Android from v1.3.0

###v1.0.0
First release
- Support for MOCA SDK for iOS from v1.3.9
