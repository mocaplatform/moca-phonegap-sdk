//
//  MOCA.h
//
//  MOCA iOS SDK
//  Version 2.0
//
//  This module is part of MOCA Platform.
//
//  Copyright (c) 2012-present InnoQuant Strategic Analytics, S.L.
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "MOCALog.h"
#import "MOCAConfig.h"
#import "MOCAEvent.h"
#import "MOCAInstance.h"
#import "MOCAUser.h"
#import "MOCAInbox.h"
#import "MOCAProximityService.h"
#import "MOCAIndoorClient.h"
#import "MOCARecoClient.h"

/**
 * MOCA object manages the shared state for all MOCA SDK services. 
 * [this method]([MOCA initialize:]) method should be called from UIApplication delegate
 * application:didFinishLaunchingWithOptions to initialize the shared instance.
 */
@interface MOCA : NSObject

/**
 * Gets the version of the MOCA library.
 *
 * @return The version of the MOCA library.
 */
+ (NSString*) version;

/**
 * Initializes the library with the specific app key and secret
 * and default configuration. The setup process initializes
 * proximity, push and analytics service.
 *
 * This method MUST be called from your application delegate's
 * `application:didFinishLaunchingWithOptions:` method,
 * and it may be called only once.
 *
 * You obtain app key and secret in MOCA Cloud Console after
 * registering your app.
 
 * The `initializeSDK` method uses `MOCAConfig.plist` configuration for initialization.
 * You must specify appKey and appSecret of your app in MOCAConfig.plist.
 * @return <code>YES</code> if successfully initialized, otherwise <code>NO</code>.
 */
+ (BOOL) initializeSDK;

/**
 * Initializes MOCA library and performs all necessary setup
 * using provided configuration.
 *
 * @param config The configuration to use.
 * @return <code>YES</code> if successfully initialized, otherwise <code>NO</code>.
 */
+ (BOOL) initializeSDK:(MOCAConfig *)config;

/**
 * The MOCA library configuration. This is set on initialize.
 *
 * @return The configuration object or nil if the library was not initialized.
 */
+ (MOCAConfig*) config;

/**
 * Gets the application key once successfully initialized.
 *
 * @return MOCA app key.
 */
+ (NSString*) appKey;

/**
 * Gets the application secret once successfully initialized.
 *
 * @return MOCA application secret.
 */
+ (NSString*) appSecret;

/**
 * Returns `YES` if the MOCA library
 * has been initialized and is ready for use,
 * and NO otherwise.
 *
 * @return YES if the library is initialized; or NO otherwise.
 */
+ (BOOL) initialized;

/**
 * Gets the current MOCA app instance object.
 *
 * @return The MOCAInstance object.
 */
+ (MOCAInstance*) currentInstance;

/**
 * Get status of the proximity service.
 *
 * @return YES if the proximity service is available and enabled, NO otherwise.
 */
+ (BOOL)proximityEnabled __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);

/**
 * Enables/disables the proximity service.
 * @param enable - if YES, start proximity service, otherwise stop proximity service.
 */
+ (void)setProximityEnabled:(BOOL)enable __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);

/**
 * Gets the current proximity service object. If service has not been enabled,
 * this function returns nil.
 *
 * This method requires iOS 7.0 or newer.
 *
 * @return The MOCAProximityService object
 */
+ (MOCAProximityService*) proximityService __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);


/**
 * Starts/stops MOCA remote push notification service (APNS).
 * @param enabled - YES to register the token/start the service, NO to unregister the token/stop service.
 */
+(void)setRemotePushEnabled:(BOOL)enabled;

/**
 * Return YES if MOCA remote push notifications are available and enabled.
 * @return YES if the the service is enabled, NO otherwise.
 */
+(BOOL)remotePushEnabled;

/**
 * Return YES if MOCA geolocation tracking service is available and enabled.
 * @return YES if the the service is enabled, NO otherwise.
 */
+(BOOL)geoTrackingEnabled;

/**
 * Starts/stops MOCA geolocation tracking service.
 * This requires event tracking service to be enabled as well in order to
 * submit data to the cloud.
 * @param enabled - YES to start the service, NO to stop service.
 */
+(void)setGeoTrackingEnabled:(BOOL)enabled;

/**
 * Return YES if MOCA event tracking service is available and enabled.
 * @return YES if the the service is enabled, NO otherwise.
 */
+(BOOL)eventTrackingEnabled;

/**
 * Starts/stops MOCA event tracking service.
 * @param enabled - YES to start the service, NO to stop service.
 *
 * If this service is enabled, MOCA collects and submits tracked events
 * to MOCA cloud.
 */
+(void)setEventTrackingEnabled:(BOOL)enabled;

/**
 * Get status of the recommendation service.
 *
 * @return YES if the service is available and enabled, NO otherwise.
 */
+ (BOOL)recoEnabled __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);

/**
 * Enables/disables the recommendations service.
 * @param enable - if YES, start the service, otherwise stop it.
 */
+ (void)setRecoEnabled:(BOOL)enable __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);

/**
 * Get status of the WiFi only transfer constraint.
 *
 * @return YES if the SDK is allowed to transmit data only when Wifi is available.
 *         NO otherwise.
 */
+ (BOOL)wifiOnlyEnabled;

/**
 * Enables/disables the WiFi only transfer contraint.
 * @param enabled - if YES the SDK is allowed to transmit data only when Wifi is available.
 *         NO otherwise.
 */
+ (void)setWifiOnlyEnabled:(BOOL)enabled;

/**
 * Get status of the Indoor Analytics service. 
 */
+ (BOOL)indoorAnalyticsEnabled;

/**
 * Enables / Disables Indoor Analytics tracking. Available for venues with Indoor Location technologies
 * installed. SDK will remember this setting in subsequent initializations.
 * @param enabled - YES to enable, NO to disable
 */
+ (void)setIndoorAnalyticsEnabled:(BOOL)enabled;

/**
 * Gets the inbox object.
 * This method requires iOS 7.0 or newer.
 *
 * @return The MOCAInbox object.
 */
+ (MOCAInbox*) inbox;

+ (CLLocation *) lastKnownLocation;

/**
 * Gets the current log level of MOCA library.
 *
 * @return Log level.
 */
+ (MOCALogLevel) logLevel;

/**
 * Sets the log level.
 *
 * @param logLevel New log level.
 */
+ (void) setLogLevel:(MOCALogLevel)logLevel;

/**
 * Creates a new recommender client for a specific item category.
 *
 * Note: the available categories must have bee previously deployed in recommendation
 * system associated whit your MOCA app.
 *
 * @param category - item category (i.e. "exhibitors", "sessions", "speakers").
 *
 * @return recommendation client object
 */
+ (MOCARecoClient*) createRecoClient:(NSString*)category;

/**
 * Tells MOCA that it can begin a cloud fetch operation if it has data to download.
 *
 * This method MUST be called from your application delegate's
 * `application:performFetchWithCompletionHandler:` method.
 *
 * You MUST enable Background Fetch mode in App Capabitilies.
 *
 * When an opportunity arises to download data, the iOS system calls your app deletage
 * `application:performFetchWithCompletionHandler:` method to give your app a chance 
 * to download any data it needs. Your implementation of this method should call
 * [MOCA performFetchWithCompletionHandler:completionHandler]
 * to download the data, prepare proximity data for use, and call the block in the 
 * completionHandler parameter.
 * 
 * This method requires iOS 7.0 or newer.
 *
 * @return YES if background fetch has been succesfully started, or NO otherwise.
 */
+(BOOL)performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_7_0);

/**
 * Updates the push device token and registers the token with MOCA cloud. This won't occur until
 * push notification is enabled for the app. This call is required.
 * This method SHOULD be called from 'appliaton:didRegisterForRemoteNotificationsWithDeviceToken:' handler.
 *
 * @param deviceToken - push token. If nil, MOCA will unregister the token.
 *
 * Example:
 *
 * - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
 * {
 *     NSLog (@"APNS device token: %@", deviceToken);
 *     // Updates the device token and registers the token with MOCA cloud.
 *     // This call is required to enabled push notifications.
 *     [MOCA registerDeviceToken:deviceToken];
 * }
 */
+(void)registerDeviceToken:(NSData*)deviceToken;

/**
 * Tells MOCA that a remote push notification has been received by the application.
 * This is called by iOS when the app is in background OR in foreground.
 *
 * This method SHOULD be called from your application delegate's
 * `application:didReceiveRemoteNotification:fetchCompletionHandler` delegate method.
 *
 * Example:
 * - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
 *       fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
 * {
 *    NSLog (@"Received remote notification: %@", userInfo);
 *
 *    // Notify MOCA handler
 *    [MOCA handleRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
 * }
 *
 */
+(void)handleRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

/**
 * Tells MOCA that a remote push notification has been received by the application.
 * 
 * This method SHOULD be called from your application delegate's
 * `application:didReceiveRemoteNotification:` delegate method.
 *
 * Example:
 * - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
 * {
 *    NSLog (@"Received remote notification: %@", userInfo);
 *
 *    // Notify MOCA handler
 *    [MOCA handleRemoteNotification:userInfo];
 * }
 *
 */
+(void)handleRemoteNotification:(NSDictionary *)userInfo;


/**
 * Tells MOCA that a local push notification has been received by the application.
 *
 * This method SHOULD be called from your application delegate's
 * `application:didReceiveLocalNotification:` delegate method.
 *
 * Example:
 * - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
 * {
 *    NSLog (@"Received local notification: %@", notification);
 *
 *    // Notify MOCA handler
 *    [MOCA handleLocalNotification:notification];
 * }
 *
 */
+(void)handleLocalNotification:(UILocalNotification *)notification;

/**
 * Checks if this specific local notification contains MOCA content.
 * MOCA content is verified by checking "moca" key in the userInfo dictionary.
 *
 * @param notification - The notification to check.
 *
 * @return YES if this is MOCA notification or NO otherwise.
 */
+(BOOL)isMocaLocalNotification:(UILocalNotification *)notification;

/**
 * Checks if this specific remote notification payload (userInfo) contains MOCA content.
 * MOCA content is verified by checking "moca" key in the userInfo dictionary.
 *
 * @param userInfo - The notification to check.
 *
 * @return YES if this is MOCA notification or NO otherwise.
 */
+(BOOL)isMocaRemoteNotification:(NSDictionary *)userInfo;


/**
 * Called when your app has been activated by the user selecting an action from a local notification.
 * A nil action identifier indicates the default action.
 * @param identifier - the notification action identifier or nil for default action
 * @param notification -  the local notification
 *
 * @return YES if the action was executed or NO otherwise.
 */
+(BOOL)handleActionWithIdentifier:(NSString *)identifier
             forLocalNotification:(UILocalNotification *)notification;

/**
 * Called when your app has been activated by the user selecting an action from a remote notification.
 * A nil action identifier indicates the default action.
 *
 * @param identifier - the notification action identifier or nil for default action
 * @param userInfo -  the local notification
 *
 * @return YES if the action was executed or NO otherwise.
 */
+(BOOL) handleActionWithIdentifier:(NSString *)identifier
             forRemoteNotification:(NSDictionary *)userInfo;

/**
 * Creates a new indoor location tracker client. Used to get user position indoors
 *
 * @return a new instance of the indoor location tracker, nil if not avaialble.
 */
+(MOCAIndoorClient*)indoorLocationClientWithDelegate: (id <MOCAIndoorDelegate>) delegate;

/**
 * Shutdown the library
 */
+(void)shutdown;

@end
