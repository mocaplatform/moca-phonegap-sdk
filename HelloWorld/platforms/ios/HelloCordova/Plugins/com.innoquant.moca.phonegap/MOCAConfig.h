//
//  MOCAConfig.h
//
//  MOCA iOS SDK
//
//  This module is part of InnoQuant MOCA Platform.
//
//  Copyright (c) 2012-2015 InnoQuant Strategic Analytics, S.L.
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
#import "MOCALog.h"

/**
 * The MOCAConfig object provides an interface for passing 
 * configurable values to [MOCA initialize].
 *
 * The simplest way to use this class is to add an MOCAConfig.plist file 
 * in your app's bundle and set the desired option values. The plist keys 
 * use exactly the same names as the properties on this class.
 */
@interface MOCAConfig : NSObject<NSCopying>

/**
 * The current app key.
 */
@property (nonatomic, readonly) NSString *      appKey;
    
/**
 * The current app secret.
 */
@property (nonatomic, readonly) NSString *      appSecret;

/**
 * The current log level for MOCA library.
 */
@property (nonatomic, readonly) MOCALogLevel    logLevel;

/**
 * The size in MB for the MOCA Disk Cache for this application.  
 * The default value is 100MB. 
 */
@property (nonatomic, readonly) NSUInteger        cacheDiskSizeInMB;

/**
 * MOCA Toast (short in-app notification message) duration in seconds.
 * The default value is 5 seconds.
 */
@property (nonatomic, readonly) NSUInteger        toastDurationSeconds;

/**
 * MOCA Toast position: @"top", @"center" or @"bottom".
 * The default value is @"top".
 */
@property (nonatomic, readonly) NSString *        toastPosition;

/**
 * If enabled, the MOCA library automatically registers for remote push
 * notifications and intercepts incoming notifications in both the foreground
 * and upon app launch.
 *
 * Defaults to YES. If this is disabled, you will need to register for 
 * remote notifications in application:didFinishLaunchingWithOptions: and 
 * forward all notification-related app delegate calls to MOCAPush.
 */
@property (nonatomic, readonly) BOOL              automaticPushSetupEnabled;

/**
 * If enabled, the MOCA library automatically initializes proximity experience
 * service and starts monitoring for iBeacons in both the foreground
 * and background modes.
 *
 * Defaults to YES. If this is disabled, the MOCA proximity experience service
 * will not be used.
 */
@property (nonatomic, readonly) BOOL              proximityServiceEnabled;

/**
 * If enabled, the MOCA library automatically tracks user geo-location.
 *
 * Defaults to YES. If this is disabled, the MOCA geo-location tracking
 * will not be used.
 */
@property (nonatomic, readonly) BOOL              geoLocationServiceEnabled;


/**
 * If disbaled, the MOCA library not track user geo-location in the background.
 *
 * Defaults to YES. If this is disabled, the MOCA background geo-location tracking
 * will not be used.
 */
@property (nonatomic, readonly) BOOL              backgroundLocationEnabled;

/**
 * If enabled the MOCA library does not send any data to the cloud.
 * Defaults to NO.
 */
@property (nonatomic, readonly) BOOL              stealthMode;


/**
 * If enabled the MOCA Proximity service starts MOCA iBeacon driver (default driver).
 * Defaults to YES.
 */
@property (nonatomic, readonly) BOOL              mocaDriverEnabled;

/**
 * Custom properties.
 */
@property (nonatomic, readonly) NSDictionary *    customProperties;


///---------------------------------------------------------------------------------------

/**
 * Creates an instance using the values set in the `MOCAConfig.plist` file.
 */
+ (MOCAConfig *)configFromBundle;

/**
 * Creates an instance using the values found in the specified `.plist` file.
 * @param path The path of the specified file.
 */
+ (MOCAConfig *)configWithContentsOfFile:(NSString *)path;

/**
 * Creates an instance with preconfigured, default values.
 */
+ (MOCAConfig *)defaultConfigForAppKey:(NSString*)appKey andSecret:(NSString*)appSecret;

/**
 * Updates AppKey and AppSecret
 */
-(void)setAppKey:(NSString*)appKey andSecret:(NSString*)appSecret;

/**
 * Set stealth mode.
 */
-(void)setStealthMode:(BOOL)stealthMode;

/**
 * Query custom property by key.
 */
-(id)valueForCustomKey:(NSString*)customKey;

@end

