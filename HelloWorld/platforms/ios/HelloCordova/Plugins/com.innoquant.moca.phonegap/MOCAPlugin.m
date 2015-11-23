//
//  MOCAPlugin.m
//  v1.6.0
//
//  MOCA PhoneGap Plugin (iOS)
//
//  This module is part of InnoQuant MOCA Platform.
//
//  Copyright (c) 2014-2015 InnoQuant Strategic Analytics, S.L.
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

#import "MOCAPlugin.h"

// ----------------------------------------------------------------------


typedef id (^UACordovaCallbackBlock)(NSArray *args);
typedef void (^UACordovaVoidCallbackBlock)(NSArray *args);

// ----------------------------------------------------------------------


@interface MOCAConfig ()

-(id)initWithDictionary:(NSDictionary*)dict;

@end

// ----------------------------------------------------------------------


/**
 * Private MOCABeacon interface.
 */
@interface MOCABeacon ()

/**
 * Beacon ID. Might be nil if not assigned.
 */
@property (readonly, nonatomic, copy) NSString * identifier;

/**
 * 4-digit beacon code (Unique). Might be nil if not assigned.
 */
@property (readonly, nonatomic, copy) NSString * code;

/**
 * Zone ID this beacon is assigned to. Might be nil if not assigned.
 */
@property (readonly, nonatomic, copy) NSString * zoneId;

@end

// ----------------------------------------------------------------------

@interface MOCAPlugin ()

- (void)initializeSDK;

@end

@implementation MOCAPlugin

- (void)pluginInitialize {
    MOCA_LOG_INFO("Initializing MOCAPlugin V1.6.0");
    [self initializeSDK];
}

- (void)initializeSDK {
    //Init MOCA config options
    NSDictionary *settings = self.commandDelegate.settings;
    // build MOCA configuration
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    // app key
    NSString * appKey = [settings valueForKey:@"moca_app_key"];
    if (!appKey) {
        MOCA_LOG_ERROR ("MOCA app key not specified in settings. Missing 'moca_app_key' parameter.");
        return;
    }
    [dict setObject:appKey forKey:@"APP_KEY"];

    // app secret
    NSString * appSecret = [settings valueForKey:@"moca_app_secret"];
    if (!appSecret) {
        MOCA_LOG_ERROR ("MOCA app secret not specified in settings. Missing 'moca_app_secret' parameter.");
        return;
    }
    [dict setObject:appSecret forKey:@"APP_SECRET"];

    // log level
    NSString * logLevelStr = [settings valueForKey:@"moca_log_level"];
    if (!logLevelStr) {
        logLevelStr = @"warning";
    }
    [dict setObject:logLevelStr forKey:@"LOG_LEVEL"];
    
    // disk size cache in MB
    [dict setObject:[NSNumber numberWithInt:100] forKey:@"CACHE_DISK_SIZE_IN_MB"];

    // automatic push setup (disabled by default)
    BOOL pushEnabled = NO;
    NSString * pushEnabledStr = [settings valueForKey:@"moca_auto_push_setup_enabled"];
    if (pushEnabledStr) {
        pushEnabled = [pushEnabledStr integerValue];
    }    
    [dict setObject:[NSNumber numberWithBool:pushEnabled] forKey:@"AUTOMATIC_PUSH_SETUP_ENABLED"];

    // proximity service (enabled by default)
    BOOL proximityEnabled = YES;
    NSString * proximityEnabledStr = [settings valueForKey:@"moca_proximity_enabled"];
    if (proximityEnabledStr) {
        proximityEnabled = [proximityEnabledStr integerValue];
    }    
    [dict setObject:[NSNumber numberWithBool:proximityEnabled] forKey:@"PROXIMITY_SERVICE_ENABLED"];

    // geo service (enabled by default)
    BOOL geoEnabled = YES;
    NSString * geoEnabledStr = [settings valueForKey:@"moca_geolocation_enabled"];
    if (geoEnabledStr) {
        geoEnabled = [geoEnabledStr integerValue];
    }    
    [dict setObject:[NSNumber numberWithBool:geoEnabled] forKey:@"GEOLOCATION_SERVICE_ENABLED"];

    // create config object
    MOCAConfig *config = [[MOCAConfig alloc] initWithDictionary:dict];
    if (!config) {
        MOCA_LOG_ERROR ("Invalid MOCA configuration. Please review your config.xml file.");
        return;
    }
        
    // Create MOCA singleton that's used to talk to MOCA cloud.
    // Please populate MOCAConfig.plist with your info.
    [MOCA initializeSDK:config];
    // Setup 'PhoneGap' distribution flag
    MOCAInstance * instance = [MOCA currentInstance];
    if (instance) {
        [instance setValue:@"PhoneGap" forProperty:@"moca_env"];
    }
    MOCAProximityService * service = [MOCA proximityService];
    if (service) {
        service.eventsDelegate = self;
        service.actionsDelegate = self;
    } else {
        MOCA_LOG_WARNING ("MOCA proximity service not available on this device.");
    }
}

- (void)performCallbackWithCommand:(CDVInvokedUrlCommand*)command 
                         expecting:(NSArray *)expected 
                         withBlock:(UACordovaCallbackBlock)block {

    dispatch_async(dispatch_get_main_queue(), ^{
        //if we're expecting any arguments
        if (expected) {
            if (![self validateArguments:command.arguments forExpectedTypes:expected]) {
                [self failWithCallbackID:command.callbackId];
                return;
            }
        } else if(command.arguments.count) {
            MOCA_LOG_ERROR(@"Parameter number mismatch: expected 0 and received %lu", (unsigned long)command.arguments.count);
            [self failWithCallbackID:command.callbackId];
            return;
        }

        //execute the block. the return value should be an obj-c object holding what we want to pass back to cordova.
        id returnValue = block(command.arguments);

        CDVPluginResult *result = [self pluginResultForValue:returnValue];
        if (result) {
            [self succeedWithPluginResult:result withCallbackID:command.callbackId];
        } else {
            [self failWithCallbackID:command.callbackId];
        }
    });
}

- (void)performCallbackWithCommand:(CDVInvokedUrlCommand*)command 
                         expecting:(NSArray *)expected 
                     withVoidBlock:(UACordovaVoidCallbackBlock)block {
    [self performCallbackWithCommand:command expecting:expected withBlock:^(NSArray *args) {
        block(args);
        return [NSNull null];
    }];
}

- (void)failWithCallbackID:(NSString *)callbackID {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:result callbackId:callbackID];
}

- (void)succeedWithPluginResult:(CDVPluginResult *)result withCallbackID:(NSString *)callbackID {
    [self.commandDelegate sendPluginResult:result callbackId:callbackID];
}

- (BOOL)validateArguments:(NSArray *)args forExpectedTypes:(NSArray *)types {
    if (args.count == types.count) {
        for (int i = 0; i < args.count; i++) {
            if (![[args objectAtIndex:i] isKindOfClass:[types objectAtIndex:i]]) {
                //fail when when there is a type mismatch an expected and passed parameter
                MOCA_LOG_ERROR(@"Type mismatch in cordova callback: expected %@ and received %@",
                        [types description], [args description]);
                return NO;
            }
        }
    } else {
        //fail when there is a number mismatch
        MOCA_LOG_ERROR(@"Parameter number mismatch in cordova callback: expected %lu and received %lu", 
             (unsigned long)types.count, (unsigned long)args.count);
        return NO;
    }

    return YES;
}

- (CDVPluginResult *)pluginResultForValue:(id)value {
    CDVPluginResult *result;

    /*
     NSSString -> String
     NSNumber --> (Integer | Double)
     NSArray --> Array
     NSDictionary --> Object
     nil --> no return value
     */

    if ([value isKindOfClass:[NSString class]]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                   messageAsString:[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        CFNumberType numberType = CFNumberGetType((CFNumberRef)value);
        //note: underlyingly, BOOL values are typedefed as char
        if (numberType == kCFNumberIntType || numberType == kCFNumberCharType) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[value intValue]];
        } else  {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:[value doubleValue]];
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:value];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:value];
    } else if ([value isKindOfClass:[NSNull class]]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        MOCA_LOG_ERROR(@"Cordova callback block returned unrecognized type: %@", NSStringFromClass([value class]));
        return nil;
    }

    return result;
}


#pragma mark Phonegap bridge: MOCA

/**
 * Parse log level from string.
 * Retur
 */
-(MOCALogLevel)logLevelFromString:(NSString*)logStr withDefault:(MOCALogLevel)defaultLevel
{
    MOCALogLevel level = defaultLevel;
    if (logStr!=nil)
    {
        logStr = [[logStr stringByTrimmingCharactersInSet:
                   [NSCharacterSet whitespaceCharacterSet]] lowercaseString];
        if ([logStr isEqualToString:@"off"])
        {
            level = Off;
        }
        else if ([logStr isEqualToString:@"error"])
        {
            level = Error;
        }
        else if ([logStr isEqualToString:@"warning"])
        {
            level = Warning;
        }
        else if ([logStr isEqualToString:@"info"])
        {
            level = Info;
        }
        else if ([logStr isEqualToString:@"debug"])
        {
            level = Debug;
        }
        else if ([logStr isEqualToString:@"trace"])
        {
            level = Trace;
        }
    }
    return level;
}

/**
 * Sets the log level.
 *
 * @param logLevel New log level.
 */
-(void) setLogLevel:(CDVInvokedUrlCommand*)command {

    CDVPluginResult* pluginResult = nil;
    
    if (command.arguments.count >= 1) {
        id obj = [command.arguments objectAtIndex:0];
        
        if ([obj isKindOfClass:[NSNumber class]]) {
            MOCALogLevel logLevel = (MOCALogLevel)[obj intValue];
            MOCA_LOG_DEBUG(@"LogLevel: %d", [obj intValue]);
            [MOCA setLogLevel:logLevel];           
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            id obj = [command.arguments objectAtIndex:0];
            NSString *logStr = (NSString*)obj;
            MOCALogLevel logLevel = [self logLevelFromString:logStr withDefault:Info];
            MOCA_LOG_DEBUG(@"LogLevel: %@", logStr);
            [MOCA setLogLevel:logLevel];  
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Starts/stops proximity service
 *
 * @param enabled - bool 
 */
-(void) setProximityEnabled:(CDVInvokedUrlCommand*)command {

    CDVPluginResult* pluginResult = nil;
    
    if (command.arguments.count >= 1) {
        id obj = [command.arguments objectAtIndex:0];
        
        if ([obj isKindOfClass:[NSNumber class]]) {
            BOOL fEnabled = [obj boolValue];
            MOCA_LOG_DEBUG(@"setProximityEnabled: %@", fEnabled?@"Enabled":@"Disabled");
            [MOCA setProximityEnabled:fEnabled];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


// GETTERS

- (void)version:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        NSString * version = [MOCA version];
        return version;
    }];
}

- (void)proximityEnabled:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        BOOL fEnabled = [MOCA proximityEnabled];
        return [NSNumber numberWithBool:fEnabled];
    }];
}

- (void)appKey:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        return [MOCA appKey];
    }];
}

- (void)appSecret:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        return [MOCA appSecret];
    }];
}

- (void)initialized:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        BOOL isInited = [MOCA initialized];
        return [NSNumber numberWithBool:isInited];
    }];
}

- (void)logLevel:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        MOCALogLevel level = [MOCA logLevel];
        return [NSNumber numberWithInt:(int)level];
    }];
}

/**
 * Fetch proximity data from cloud.
 * (performFetchWithCompletionHandler)
 */
 - (void)performFetch:(CDVInvokedUrlCommand*)command {

    dispatch_async(dispatch_get_main_queue(), ^{
        //if we're expecting any arguments
        if(command.arguments.count) {
            MOCA_LOG_ERROR(@"Parameter number mismatch: expected 0 and received %d", command.arguments.count);
            [self failWithCallbackID:command.callbackId];
            return;
        }
        __block id returnValue;
        //execute the block. the return value should be an obj-c object holding what we want to pass back to cordova.
        [MOCA performFetchWithCompletionHandler:^(UIBackgroundFetchResult result) {
            // callback function invoked when the fetch completes with either success or error.
            switch (result) {
                case UIBackgroundFetchResultNewData:
                    MOCA_LOG_DEBUG(@"New data available");
                    returnValue = [NSNumber numberWithInt:1];
                    break;
                case UIBackgroundFetchResultNoData:
                    MOCA_LOG_DEBUG(@"No changes");
                    returnValue = [NSNumber numberWithInt:0];
                    break;
                case UIBackgroundFetchResultFailed:
                    MOCA_LOG_ERROR(@"Fetch failed. Try again later.");
                    returnValue = [NSNumber numberWithInt:1];
                    break;
                default:
                    MOCA_LOG_ERROR(@"Should never happen");
                    break;            
            }
        }];
        CDVPluginResult *result = [self pluginResultForValue:returnValue];
        if (result) {
            [self succeedWithPluginResult:result withCallbackID:command.callbackId];
        } else {
            [self failWithCallbackID:command.callbackId];
        }
    });
}

// registerDeviceToken

// +(void)handleRemoteNotification:(NSDictionary *)userInfo;

// +(void)handleLocalNotification:(UILocalNotification *)notification;

// +(BOOL)isMocaNotification:(UILocalNotification *)notification;

// +(BOOL)handleActionWithIdentifier:(NSString *)identifier
//             forLocalNotification:(UILocalNotification *)notification; 

// +(void)shutdown;

#pragma mark

#pragma mark Phonegap bridge: MOCA Instance

// GETTERS

- (void)instance_identifier:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        MOCAInstance * instance = [MOCA currentInstance];
        NSString * identifier = instance ? instance.identifier : nil;
        return identifier;
    }];
}

- (void)instance_deviceToken:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        MOCAInstance * instance = [MOCA currentInstance];
        NSString * token = instance ? instance.deviceToken : nil;
        return token;
    }];
}

- (void)instance_session:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        MOCAInstance * instance = [MOCA currentInstance];
        NSNumber * session = instance ? instance.session : nil;
        return session;
    }];
}

- (void)instance_birthDay:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        MOCAInstance * instance = [MOCA currentInstance];
        NSNumber * birthDay = instance ? instance.birthDay : nil;
        return birthDay;
    }];
}

- (void)instance_pushEnabled:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        MOCAInstance * instance = [MOCA currentInstance];
        BOOL enabled = instance ? instance.pushEnabled : NO;
        return [NSNumber numberWithBool:enabled];
    }];
}

- (void)instance_userLoggedIn:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        MOCAInstance * instance = [MOCA currentInstance];
        BOOL loggedIn = NO;
        if (instance) {
            loggedIn = instance.currentUser != nil;
        }
        return [NSNumber numberWithBool:loggedIn];
    }];
}

/**
 * Login user
 *
 * @param userId
 */
-(void) instance_userLogin:(CDVInvokedUrlCommand*)command {

    CDVPluginResult* pluginResult = nil;
    
    if (command.arguments.count >= 1) {
        id obj = [command.arguments objectAtIndex:0];
        
        if ([obj isKindOfClass:[NSString class]]) {
            NSString* userId = (NSString*)obj;
            MOCAInstance * instance = [MOCA currentInstance];
            if (instance && userId)
            {
                MOCA_LOG_DEBUG(@"Login User with ID=: %@", userId);
                [instance login:userId];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }
    } 
    if (!pluginResult) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 * Logout user
 *
 * @param userId
 */
-(void) instance_userLogout:(CDVInvokedUrlCommand*)command {

    CDVPluginResult* pluginResult = nil;
    
    MOCAInstance * instance = [MOCA currentInstance];    
    if (instance)
    {
        MOCAUser * user = instance.currentUser;
        if (user) 
        {
            MOCA_LOG_DEBUG(@"Logout User with ID=: %@", user.identifier);
            [user logout];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
    } 
    if (!pluginResult) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set custom property
 *
 * @param userId
 */
-(void) instance_setCustomProperty:(CDVInvokedUrlCommand*)command {

    CDVPluginResult* pluginResult = nil;
    
    if (command.arguments.count >= 2) {
        id key = [command.arguments objectAtIndex:0];
        id value = [command.arguments objectAtIndex:1];
        if ([key isKindOfClass:[NSString class]]) {
            MOCAInstance * instance = [MOCA currentInstance];
            if (instance && key)
            {
                MOCA_LOG_DEBUG(@"Set Custom Property %@=%@", key, value);
                [instance setValue:value forProperty:(NSString*)key];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }
    } 
    if (!pluginResult) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


// save with block
// login
// currentUser
// setValue:forProperty:
// valueForProperty:
// allProperties


#pragma mark


#pragma mark Phonegap bridge: MOCA User

// save with block
// setValue:forProperty:
// valueForProperty:
// allProperties
// logout

#pragma mark

#pragma mark Phonegap bridge: MOCA User

// addTag
// addTag:withValue
// containsTag
// getTagValue
// getTopTags
// allTags

#pragma mark

#pragma mark Phonegap bridge: Proximity Event Callbacks

/**
 * Method triggered when iOS device detects a new beacon.
 *
 * @param service proximity service
 * @param beacon MOCA beacon
 *
 * @return void
 */
-(void)proximityService:(MOCAProximityService*)service
          didEnterRange:(MOCABeacon *)beacon
          withProximity:(CLProximity)proximity
{
    NSDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:beacon.identifier forKey:@"identifier"];
    [args setValue:beacon.name forKey:@"name"];
    if (beacon.code) {
        [args setValue:beacon.code forKey:@"code"];
    }
    [args setValue:[NSNumber numberWithInt:proximity] forKey:@"proximity"];
    [self fireDocumentEvent:@"moca.enterbeacon" withArgs:args];
}

/**
 * Method triggered when iOS device lost the connection to previously detected beacon.
 *
 * @param service proximity service
 * @param beacon MOCA beacon
 *
 * @return void
 */
-(void)proximityService:(MOCAProximityService*)service
           didExitRange:(MOCABeacon *)beacon
{
    NSDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:beacon.identifier forKey:@"identifier"];
    [args setValue:beacon.name forKey:@"name"];
    [self fireDocumentEvent:@"moca.exitbeacon" withArgs:args];
}


/**
 * Method triggered when the state of a beacon proximity did changed.
 *
 * @param service proximity service
 * @param beacon MOCA beacon
 * @param prevProximity - previous beacon proximity state
 * @param curProximity - current beacon proximity state
 *
 * @return void
 */
-(void)proximityService:(MOCAProximityService*)service
didBeaconProximityChange:(MOCABeacon*)beacon
          fromProximity:(CLProximity)prevProximity
            toProximity:(CLProximity)curProximity
{
    NSDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:beacon.identifier forKey:@"identifier"];
    [args setValue:[NSNumber numberWithInt:prevProximity] forKey:@"prevProximity"];
    [args setValue:[NSNumber numberWithInt:curProximity] forKey:@"curProximity"];
    [self fireDocumentEvent:@"moca.beaconproximitychange" withArgs:args];
}

/**
 * Method triggered when iOS device did entered a place.
 *
 * @param service proximity service
 * @param place MOCA place
 *
 * @return void
 */
-(void)proximityService:(MOCAProximityService*)service
          didEnterPlace:(MOCAPlace *)place
{
    NSDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:place.identifier forKey:@"identifier"];
    [args setValue:place.name forKey:@"name"];
    [self fireDocumentEvent:@"moca.enterplace" withArgs:args];
}

/**
 * Method triggered when iOS device did exit place.
 *
 * @param service proximity service
 * @param place MOCA place
 *
 * @return void
 */
-(void)proximityService:(MOCAProximityService*)service
           didExitPlace:(MOCAPlace *)place
{
    NSDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:place.identifier forKey:@"identifier"];
    [args setValue:place.name forKey:@"name"];
    [self fireDocumentEvent:@"moca.exitplace" withArgs:args];
}

/**
 * Method triggered when iOS device did entered a specific zone of a place.
 *
 * @param service proximity service
 * @param zone MOCA zone
 *
 * @return void
 */
-(void)proximityService:(MOCAProximityService*)service
           didEnterZone:(MOCAZone *)zone
{
    NSDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:zone.identifier forKey:@"identifier"];
    [args setValue:zone.name forKey:@"name"];
    if (zone.floorNumber) {
        [args setValue:zone.floorNumber forKey:@"floorNumber"];
    }
    if (zone.shortId) {
        [args setValue:zone.shortId forKey:@"shortId"];
    }
    if (zone.place) {
        [args setValue:zone.place.identifier forKey:@"placeId"];
    }
    [self fireDocumentEvent:@"moca.enterzone" withArgs:args];
}

/**
 * Method triggered when iOS device did exit a specific zone of a place.
 *
 * @param service proximity service
 * @param zone MOCA zone
 *
 * @return void
 */
-(void)proximityService:(MOCAProximityService*)service
            didExitZone:(MOCAZone *)zone
{
    NSDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:zone.identifier forKey:@"identifier"];
    [args setValue:zone.name forKey:@"name"];
    if (zone.floorNumber) {
        [args setValue:zone.floorNumber forKey:@"floorNumber"];
    }
    if (zone.shortId) {
        [args setValue:zone.shortId forKey:@"shortId"];
    }
    if (zone.place) {
        [args setValue:zone.place.identifier forKey:@"placeId"];
    }
    [self fireDocumentEvent:@"moca.exitzone" withArgs:args];
}

/**
 * Method invoked when a proximity experience scheduled in MOCA-cloud
 * needs to evaluate a custom trigger.
 *
 * @param service proximity service
 * @param customAttribute custom trigger attribute string. Defined in MOCA console.
 *
 * @return YES if the custom trigger fired, or NO otherwise.
 */
-(BOOL)proximityService:(MOCAProximityService*)service
    handleCustomTrigger:(NSString*)customAttribute
{
    NSDictionary *args = [[NSMutableDictionary alloc] init];
    if (customAttribute) {
        [args setValue:customAttribute forKey:@"customAttribute"];
    } else {
        [args setValue:@"" forKey:@"customAttribute"];
    }
    [self fireDocumentEvent:@"moca.customTrigger" withArgs:args];
    return YES;
}

/**
 * Method invoked when a proximity service loaded or updated a registry of beacons
 * from MOCA cloud.
 *
 * @param service proximity service
 * @param beacons current collection of registered beacons
 *
 * @return YES if the custom trigger fired, or NO otherwise.
 */
-(void)proximityService:(MOCAProximityService*)service
   didLoadedBeaconsData:(NSArray*)beacons
{
    NSDictionary *args = [[NSMutableDictionary alloc] init];
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for(MOCABeacon * b in beacons) {
        NSDictionary *bObj = [[NSMutableDictionary alloc] init];
        [bObj setValue:b.identifier forKey:@"identifier"];
        [bObj setValue:b.name forKey:@"name"];
        if (b.code) {
            [bObj setValue:b.code forKey:@"code"];
        }
        [arr addObject: bObj];
    }
    [args setValue:arr forKey:@"beacons"];
    [self fireDocumentEvent:@"moca.dataready" withArgs:args];
}

/**
 * Create and dispatch custom JavaScript event with given arguments.
 *
 * The JavaScript developer must register for custom events in the following way:
 * document.addEventListener("moca.enterplace", onEnterPlace, false);
 *
 *  function onEnterPlace(event) {
 *     // Called when MOCA detected user entering a place.
 *   }
 */
-(void)fireDocumentEvent:(NSString*)eventName withArgs:(NSDictionary*)args
{
    if (self.commandDelegate) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args
                                                           options:0
                                                             error:&error];
        
        if (!jsonData) {
            MOCA_LOG_ERROR(@"fireDocumentEvent failed due to JSON serialization error: %@", error.localizedDescription);
            return;
        }
        NSString * dictJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        // create and dispatch JavaScript custom event
        NSString * js = [NSString stringWithFormat:@"var e = new CustomEvent('%@', { 'detail': %@ });document.dispatchEvent(e);", eventName, dictJsonStr];
        MOCA_LOG_INFO(@"[MOCA calling JS]: %@", js);
        [self.commandDelegate evalJs:js scheduledOnRunLoop:YES];
    }
}

/*
 * Called when the app should execute a custom action.
 * @param customAttribute - user provided custom attribute
 */
-(void)performCustomAction:(NSString*)customAttribute
{
    NSDictionary *args = [[NSMutableDictionary alloc] init];
    if (customAttribute) {
        [args setValue:customAttribute forKey:@"customAttribute"];
    } else {
        [args setValue:@"" forKey:@"customAttribute"];
    }
    [self fireDocumentEvent:@"moca.customaction" withArgs:args];
}



@end

