//
//  MOCA.h
//
//  MOCA iOS SDK
//  Version 2.x
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
#import "MOCACart.h"

@import UserNotifications;

/**
 * MOCA object manages the shared state for all MOCA SDK services. 
 * [this method]([MOCA initialize:]) method should be called from UIApplication delegate
 * application:didFinishLaunchingWithOptions to initialize the shared instance.
 */
@interface MOCA : NSObject

@property (class, nonatomic, readonly) MOCACart *cart;

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
 * Gets the logged-in MOCA user object.
 *
 * @return The MOCAUser object or nil if not logged in.
 */
+ (MOCAUser*) currentUser;

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
 * Return the status of notifications
 * @return YES if the notifications are muted, NO otherwise
 */
+ (BOOL)areNotificationsMuted;

/**
 * Enables/disables the "WiFi only" transfer contraint.
 * @param enabled - if YES the SDK is allowed to transmit data only when Wifi is available.
 *         NO otherwise.
 */
+ (void)setWifiOnlyEnabled:(BOOL)enabled;

/** Allows or prevents MOCA SDK from showing notifications
 * @param enabled If YES, MOCA SDK will mute notifications. If NO, notifications will be shown normally
 */
+ (void)muteNotifications:(BOOL)enabled;

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
 * Returns the last known location known by MOCA.
 *
 * @return Last known location
 */
+ (CLLocation*) getLastKnownLocation;

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

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler  NS_AVAILABLE_IOS(10_0);

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  NS_AVAILABLE_IOS(10_0);

/**
 * Checks if this specific local notification contains MOCA content.
 * MOCA content is verified by checking "moca" key in the userInfo dictionary.
 *
 * @param notification - The notification to check.
 *
 * @return YES if this is MOCA notification or NO otherwise.
 * @deprecated Use MOCA isMocaNotification: instead
 */
+(BOOL)isMocaLocalNotification:(UILocalNotification *)notification DEPRECATED_MSG_ATTRIBUTE("Use [MOCA isMocaNotification:notification] instead");

/**
 * Checks if this specific remote notification payload (userInfo) contains MOCA content.
 * MOCA content is verified by checking "moca" key in the userInfo dictionary.
 *
 * @param userInfo - The notification to check.
 *
 * @return YES if this is MOCA notification or NO otherwise.
 * @deprecated Use MOCA isMocaNotification: instead
 */
+(BOOL)isMocaRemoteNotification:(NSDictionary *)userInfo DEPRECATED_MSG_ATTRIBUTE("Use [MOCA isMocaNotification:notification] instead");

/**
 * Check if the notification is a MOCA generated notification (remote or local)
 *
 * @param notification the actual notification to check. It could be a NSDictionary (userInfo), UNNotification or UNNotificationResponse
 *
 * @return YES if is a MOCA generated notification or NO otherwise.
 */
+(BOOL)isMocaNotification:(id)notification;

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
 * Tracks a view item event.
 *
 * @param itemId identifier
 */
+(void) trackViewed:(NSString*) itemId;

/**
 * Tracks a view item event.
 *
 * @param itemId - item identifier
 * @param category - item category (optional)
 */
+(void) trackViewed:(NSString*) itemId belongingTo:(NSString*)category;

/**
 * Tracks a view item event.
 *
 * @param itemId    item identifier
 * @param recommended - YES if the item was recommended to the user, NO if user viewed the item by herself.
 */
+(void) trackViewed:(NSString*) itemId withReco:(BOOL)recommended;

/**
 * Tracks a view item event.
 *
 * @param itemId - item identifier
 * @param category - item category (optional)
 * @param recommended - YES if the item was recommended to the user, NO if user viewed the item by herself.
 */
+(void) trackViewed:(NSString*) itemId belongingTo:(NSString*)category withReco:(BOOL)recommended;

/**
 * Adds an item to the favourite list of current user. Current user can be anonymous
 * (MOCAInstance) or logged-in (MOCAUser).
 *
 * @param itemId item identifier
 * @return <code>YES</code> in case of success, <code>NO</code> in case the item already exist in the set.
 */
+(BOOL) addToFavList:(NSString*) itemId;

/**
 * Removes all items from the current user's favourites list.
 */
+(void) clearFavList;

/**
 * Removes an item from the favourite list of current user.
 *
 * @param itemId item identifier
 * @return <code>YES</code> in case of success, <code>NO</code> if the element does not belong to the set.
 */
+(BOOL) removeFromFavList:(NSString*) itemId;

/**
 * Adds an item to the wish list of current user.
 *
 * @param itemId item identifier
 * @return <code>YES</code> in case of success, <code>NO</code> in case the item already exist in the set.
 */
+(BOOL) addToWishList:(NSString*) itemId;

/**
 * Removes an item from the wish list of current user.
 *
 * @param itemId item identifier
 * @return <code>YES</code> in case of success, <code>NO</code> if the element does not belong to the set.
 */
+(BOOL) removeFromWishList:(NSString*) itemId;

/**
 * Removes all items from the current user's wish list.
 */
+(void) clearWishList;

/**
 * Creates an item that represents a product and its price with a unique identifier
 * that can be added to the cart or purchased.
 *
 * Developer note:
 * MOCA item represents an immutable object that can be viewed or purchased by a User.
 * The item has an unique identifier @itemId and a collection of properties that describe
 * its unit price, currency, and the category this item belongs to.
 *
 * @param itemId - item identifier
 * @param category - item category (optional)
 * @param unitPrice - price of a single item
 * @param currency - 3-letter currency ISO code or virtual currency name
 *
 * Example:
 *      MOCAItem * shoes = [MOCA.createItem:@"sku78192" belongingTo:@"shoes" withUnitPrice:@75.0 withCurrency:@"EUR"];
 *      [MOCA addToCart:shoes withQuantity:@2];
 */
+(id<MOCAItem>) createItem:(NSString*) itemId
            belongingTo:(NSString*) category
          withUnitPrice:(double) unitPrice
           withCurrency:(NSString*) currency;

/**
 * Adds an item to current user's cart.
 *
 * Developer note: please implement MOCAItem interface and deliver detailed information
 * about items in your Application.
 *
 * @param item - item object to add to the cart. You may use MOCA.createItem (...) method
 *             to create the item object or alternatively implement MOCAItem interface
 *             in your App object model.
 *
 * @param quantity  number of items to add to the cart
 */
+(void) addToCart:(id <MOCAItem>) item
      withQuantity:(NSUInteger) quantity;

/**
 * Updates the quantity of a specific item with @itemId in the current user's cart.
 *
 * @param itemId  item identifier
 * @param quantity new number of units to set.
 *
 * @return <code>YES</code> in case of success, <code>NO</code> in case of item is not in the cart.
 */
+(BOOL) updateCart:(NSString*) itemId
      withQuantity:(NSUInteger) quantity;

/**
 * Removes an item from current user's cart.
 *
 * @param itemId  item identifier
 *
 * @return <code>YES</code> in case of success, <code>NO</code> in case of error.
 */
+(BOOL) removeFromCart:(NSString*) itemId;

/**
 * Clears current user's cart.
 */
+(void) clearCart;

/**
 * Begins checkout of current user's cart.
 */
+(void) beginCheckout;

/**
 * Completed previously started checkout of current user's cart
 * confirming that the operation has completed successfully and the user has
 * purchased the items. After the operation the cart is cleared and
 * user's Life-Time-Value (LTV) is incremented.
 */
+(void) completeCheckout;

/**
 * Tracks an item purchased event.
 *
 * @param itemId product identifier
 * @param category  category the product belongs to.
 * @param quantity  number of units
 * @param unitPrice unit price
 * @param currency  price currency
 */
+(void) trackPurchased:(NSString*) itemId
           belongingTo:(NSString*) category
         withUnitPrice:(double) unitPrice
          withCurrency:(NSString*) currency
          withQuantity:(NSUInteger) quantity;

/**
 * Tracks an item purchased event.
 *
 * @param item  purchased product object
 * @param quantity number of units
 */
+(void) trackPurchased:(id <MOCAItem>) item
          withQuantity:(NSUInteger) quantity;

/**
 * Tracks an item shared event.
 *
 * @param itemId     item identifier
 * @param category category the item belongs to.
 */
+(void) trackShared:(NSString*) itemId
       withCategory:(NSString*) category;

/**
 * Tracks an item shared event.
 *
 * @param itemId item identifier
 */
+(void) trackShared:(NSString*) itemId;

/**
 * Tracks an item rated event.
 *
 * @param itemId     item identifier
 * @param category category the item belongs to.
 * @param rating    rating value
 */
+(void) trackContentRated:(NSString*) itemId
             withCategory:(NSString*) category
               withRating:(double) rating;

/**
 * Tracks an item rated event.
 *
 * @param itemId     item identifier
 * @param rating    rating value
 */
+(void) trackContentRated:(NSString*) itemId
               withRating:(double) rating;

/**
 * Adds a tag to the current profile (user if logged in, anonymous user if not)
 * @param tagName the name of the tag
 * @param value the value of the tag. It should have
 *   For example "+1" increments the tag value by 1.
 *   For example "-2" decrements the tag value by 2.
 *   For example "3" or "=3" assign value of 3 to the tag's value.
 */
+ (void)addTag:(NSString *)tagName withValue:(NSString *)value;

/**
 * Shutdown the library
 */
+(void)shutdown;

@end
