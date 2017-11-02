//
//  MOCAPlugin.m
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
#import "MOCAAutoIntegration.h"
#import "MOCABeacon.h"

// ----------------------------------------------------------------------

static NSString *MOCAPluginVersion = @"2.5.4";
typedef id (^UACordovaCallbackBlock)(NSArray *args);
typedef void (^UACordovaVoidCallbackBlock)(NSArray *args);

// ----------------------------------------------------------------------


@interface MOCAConfig ()

-(id)initWithDictionary:(NSDictionary*)dict;

@end

@interface MOCAPlugin ()

@property (nonatomic, strong) MOCAPluginEventsDelegate* eventsDelegate;
@property (nonatomic, strong) MOCAPluginActionsDelegate* actionsDelegate;

- (void)initializeSDK;

@end

@implementation MOCAPlugin

- (void)pluginInitialize {
    if ([MOCA initialized]) {
        return;
    }
    MOCA_LOG_INFO("Initializing MOCAPlugin %@", MOCAPluginVersion);
    [MOCAAutoIntegration autoIntegrate];
    [self initializeSDK];
}

+ (NSDictionary *)configurationDictionaryFromCordova: (NSDictionary *)settings {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    // app key
    NSString * appKey = [settings valueForKey:@"moca_app_key"];
    if (!appKey) {
        MOCA_LOG_ERROR ("MOCA app key not specified in settings. Missing 'moca_app_key' parameter.");
        return nil;
    }
    [dict setObject:appKey forKey:@"APP_KEY"];
    
    // app secret
    NSString * appSecret = [settings valueForKey:@"moca_app_secret"];
    if (!appSecret) {
        MOCA_LOG_ERROR ("MOCA app secret not specified in settings. Missing 'moca_app_secret' parameter.");
        return nil;
    }
    [dict setObject:appSecret forKey:@"APP_SECRET"];
    
    // log level
    NSString * logLevelStr = [settings valueForKey:@"moca_log_level"];
    if (!logLevelStr) {
        logLevelStr = @"warning";
        [dict setObject:logLevelStr forKey:@"LOG_LEVEL"];
    }
    
    
    // disk size cache in MB
    [dict setObject:[NSNumber numberWithInt:100] forKey:@"CACHE_DISK_SIZE_IN_MB"];
    
    // automatic push setup (disabled by default)
    BOOL pushEnabled = NO;
    NSString * pushEnabledStr = [settings valueForKey:@"moca_auto_push_setup_enabled"];
    if (pushEnabledStr) {
        pushEnabled = [pushEnabledStr integerValue];
        [dict setObject:[NSNumber numberWithBool:pushEnabled] forKey:@"AUTOMATIC_PUSH_SETUP_ENABLED"];
    }
    
    
    // proximity service (enabled by default)
    BOOL proximityEnabled = YES;
    NSString * proximityEnabledStr = [settings valueForKey:@"moca_proximity_enabled"];
    if (proximityEnabledStr) {
        proximityEnabled = [proximityEnabledStr integerValue];
        [dict setObject:[NSNumber numberWithBool:proximityEnabled] forKey:@"PROXIMITY_SERVICE_ENABLED"];
    }
    
    
    // geo service (enabled by default)
    BOOL geoEnabled = YES;
    NSString * geoEnabledStr = [settings valueForKey:@"moca_geolocation_enabled"];
    if (geoEnabledStr) {
        geoEnabled = [geoEnabledStr integerValue];
        [dict setObject:[NSNumber numberWithBool:geoEnabled] forKey:@"GEOLOCATION_SERVICE_ENABLED"];
    }
    
    return dict;
}


- (void)initializeSDK {
    //Init MOCA config options
    NSDictionary *settings = self.commandDelegate.settings;
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    // build MOCA configuration
    NSDictionary *dict = [MOCAPlugin configurationDictionaryFromCordova:settings];
    MOCAConfig *config = [[MOCAConfig alloc] initWithDictionary:dict];
    if (!config) {
        MOCA_LOG_ERROR ("Invalid MOCA configuration. Please review your config.xml file.");
        return;
    }
        
    // Create MOCA singleton that's used to talk to MOCA cloud.
    // Please populate MOCAConfig.plist with your info.
    if(![MOCA initialized]) {
        [MOCA initializeSDK:config];
        [preferences setObject:dict forKey:@"MOCA_CONFIG"];
    }
    

    // Setup 'PhoneGap' distribution flag
    MOCAInstance * instance = [MOCA currentInstance];
    if (instance) {
        [instance setValue:@"PhoneGap" forProperty:@"moca_env"];
    }
    MOCAProximityService * service = [MOCA proximityService];
    if (service) {
        self.eventsDelegate = [MOCAPluginEventsDelegate withCommandDelegate: self.commandDelegate];
        self.actionsDelegate = [MOCAPluginActionsDelegate delegateWithDefault: [service actionsDelegate]
                                                           andCommandDelegate: self.commandDelegate];
        
        [service eventsDelegate:self.eventsDelegate];
        [service actionsDelegate:self.actionsDelegate];
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
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
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

- (void)returnResponse:(CDVPluginResult *)result withCallbackId:(NSString *) callbackId {
    if(!result) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

- (void)failWithCallbackID:(NSString *)callbackId {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

-(void) failWithCallbackId: (NSString *) callbackId andMessage: (NSString *) message {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
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
     NSError -> Error
     nil --> Error
     */

    if ([value isKindOfClass:[NSError class]] || !value){
        NSString *errorString = [((NSError* )value) description];
        result =  [self errorPluginResultWithMessage: errorString];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                   messageAsString:[value stringByAddingPercentEncodingWithAllowedCharacters:set]];
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

/**
 * Starts/stops geotracking service
 *
 * @param enabled - bool 
 */
-(void) setGeoTrackingEnabled:(CDVInvokedUrlCommand*)command {

    CDVPluginResult* pluginResult = nil;
    
    if (command.arguments.count >= 1) {
        id obj = [command.arguments objectAtIndex:0];
        
        if ([obj isKindOfClass:[NSNumber class]]) {
            BOOL fEnabled = [obj boolValue];
            MOCA_LOG_DEBUG(@"setGeoTrackingEnabled: %@", fEnabled?@"Enabled":@"Disabled");
            [MOCA setGeoTrackingEnabled:fEnabled];
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

-(void)current_instance:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^(NSArray *args){
        MOCAInstance *currentInstance = [MOCA currentInstance];
        NSMutableDictionary *props =  [[currentInstance serialize] mutableCopy];
        //normalize API
        props[@"id"] = props[@"_id"];
        [props removeObjectForKey:@"_id"];
        return props;
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
            MOCA_LOG_ERROR(@"Parameter number mismatch: expected 0 and received %lu", (unsigned long)command.arguments.count);
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

#pragma mark TAG API

- (void)instance_add_tag:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSUInteger argCount = command.arguments.count;
    if(argCount == 0) {
        pluginResult =  [self errorPluginResultWithMessage:@"Invalid number of arguments."];
    }
    else {
        NSArray *args = command.arguments;
        NSString *tagName = @"";
        NSString *value = @"+1";
        @try {
            tagName = [self validTagNameForObject: args[0]];
        
            if(argCount >= 2) {
                value = [self validTagValueForObject: args[1]];
            }
        
            MOCAInstance * instance =  [MOCA currentInstance];
            if (instance != nil) {
                [instance addTag:tagName withValue:value];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
            else {
                pluginResult = [self errorPluginResultWithMessage:@"Internal MOCA SDK Error"];
            }
        } @catch(NSException *e) {
            pluginResult = [self errorPluginResultWithMessage:e.description];
        }
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)instance_remove_tag:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    NSUInteger argCount = command.arguments.count;
    if(argCount > 0) {
        @try {
            NSString *tagName = [self validTagNameForObject: command.arguments[0]];
            MOCAInstance *instance =  [MOCA currentInstance];
            if (instance != nil) {
                [instance removeTag:tagName];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            else {
                pluginResult = [self errorPluginResultWithMessage:@"Internal MOCA SDK Error"];
            }
        } @catch(NSException *e) {
            pluginResult = [self errorPluginResultWithMessage:e.description];
        }
    }
    else {
        pluginResult =  [self errorPluginResultWithMessage:@"Invalid number of arguments."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)instance_contains_tag:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    NSUInteger argCount = command.arguments.count;
    if(argCount > 0) {
        @try {
            NSString *tagName = [self validTagNameForObject: command.arguments[0]];
            MOCAInstance *instance =  [MOCA currentInstance];
            if (instance != nil) {
                BOOL isTagContained = [instance containsTag:tagName];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isTagContained];
            }
        } @catch(NSException *e) {
            pluginResult = [self errorPluginResultWithMessage:e.description];
        }
    }
    else {
        pluginResult = [self errorPluginResultWithMessage:@"Invalid number of arguments. Need 1 (tag name to be removed), found 0"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)instance_get_value_for_tag:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    NSUInteger argCount = command.arguments.count;
    if(argCount > 1) {
        @try {
            NSString *tagName = [self validTagNameForObject: command.arguments[0]];
            MOCAInstance *instance =  [MOCA currentInstance];
            if (instance != nil) {
                NSNumber *value = [instance getTagValue:tagName];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:value.intValue];
            }
        } @catch(NSException *e) {
            pluginResult = [self errorPluginResultWithMessage:e.description];
        }
    }
    else {
        pluginResult = [self errorPluginResultWithMessage:@"Invalid number of arguments. Need 1 (tag name), found 0"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)instance_get_all_tags:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    NSArray *tags = [[NSArray alloc] init];
    @try {
        MOCAInstance *instance =  [MOCA currentInstance];
        if (instance != nil) {
            tags = [instance getTopTags:1000];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:tags];
        }
    } @catch(NSException *e) {
        pluginResult = [self errorPluginResultWithMessage:e.description];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark TAG API Helpers

-(NSString *) validTagNameForObject: (id) object {
    if ([object isKindOfClass:[NSString class]]) {
        return [object stringValue];
    } else {
        [NSException raise:@"InvalidArgumentException" format:@"Tag name must be a String. Found %@", NSStringFromClass([object class])];
    }
    return nil;
}

-(NSString *)validTagValueForObject: (id) object {
    if(object == nil || [object isKindOfClass:[NSNull class]]) {
        return @"+1";
    }
    if ([object isKindOfClass:[NSString class]]) {
        NSString *tagValue = [object stringValue];
        NSString *pattern = @"^[+-=][0-9]+$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        if ([predicate evaluateWithObject: tagValue]){
            return tagValue;
        }
        else {
            [NSException raise:@"InvalidArgumentException"
                        format:@"Tag value not valid. Should be, for instance, '+1' '-2' '=3'. Found %@ ", tagValue];
            return nil;
        }
    }
    [NSException raise:@"InvalidArgumentException"
                format:@"Tag value must be a String. For instance: '+1' '-2' '=3'"];
    return nil;
}

-(CDVPluginResult *) errorPluginResultWithMessage:(NSString *) errorMessage {
    MOCA_LOG_ERROR("%@",errorMessage);
    return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
}


/**
 * Login user
 *
 * @param userId
 */
-(void) instance_userLogin:(CDVInvokedUrlCommand*)command {

    NSString * callbackId = command.callbackId;
    if(command.arguments.count < 1) {
        [self failWithCallbackId:callbackId andMessage:@"Incorrect number of arguments, expected at least 1."];
        return;
    }
    id obj = [command.arguments objectAtIndex:0];
    if (![obj isKindOfClass:[NSString class]]) {
        [self failWithCallbackId:callbackId andMessage:@"NSString identifier was expected"];
        return;
    }
    NSString* userId = (NSString*)obj;
    MOCAInstance * instance = [MOCA currentInstance];
    if(!instance) {
        [self failWithCallbackId:callbackId andMessage:@"MOCA Instance unavailable. Is MOCA SDK initialized?"];
        return;
    }
    if(!userId) {
        [self failWithCallbackId:callbackId andMessage:@"Failed to get userId."];
        return;
    }
    MOCA_LOG_DEBUG(@"Login User with ID=: %@", userId);
    [instance login:userId];
    MOCAUser *user = [instance currentUser];
    if(!user) {
        [self failWithCallbackId:callbackId andMessage:@"User login failed. Please contact support@mocaplatform.com"];
        return;
    }
    [user saveWithBlock:^(MOCAUser *user, NSError *err) {
        if(err) {
            NSString *errorMessage = [NSString stringWithFormat:@"Failed to save user in MOCA Cloud: %@", [err description]];
            [self failWithCallbackId:callbackId andMessage:errorMessage];
            return;
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
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

#pragma mark USER API

-(void) current_user:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command expecting:nil withBlock:^id(NSArray *args){
        MOCAInstance *instance = [MOCA currentInstance];
        if(!instance) {
            return [self returnErrorInstanceNotAvailableForCallbackId:command.callbackId];
        }
        MOCAUser *user = [instance currentUser];
        return [user serialize];
    }];
}

-(void) user_save:(CDVInvokedUrlCommand*)command {
    MOCAInstance *instance = [MOCA currentInstance];
    if(!instance) {
        [self failWithCallbackId:command.callbackId andMessage:@"MOCA SDK not initialized."];
        return;
    }
    MOCAUser *user = [instance currentUser];
    [user saveWithBlock:^(MOCAUser * user, NSError * err) {
        if(err) {
            [self failWithCallbackId:command.callbackId andMessage:@"Error trying to save user to MOCA Cloud"];
        }
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void) user_set_custom_property:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command
                           expecting:@[[NSString class], [NSObject class]]
                           withBlock:^id(NSArray *args){
                                MOCAInstance *instance = [MOCA currentInstance];
                                if(!instance) {
                                    return [self returnErrorInstanceNotAvailableForCallbackId:command.callbackId];
                                }
                                MOCAUser *user = [instance currentUser];
                                if(!user) {
                                    return [self errorPluginResultWithMessage:@"User is no longer logged in, cannot set property"];
                                }
                               NSString *keyObj = args[0];
                               id keyValue = args[1];
                               if([keyValue isKindOfClass:[NSNumber class]] || [keyValue isKindOfClass:[NSString class]]) {
                                   [user setValue:keyValue forProperty:keyObj];
                                   return @"User saved";
                               }
                               return [self errorPluginResultWithMessage:@"Value type is not valid"];
                            }];
}

/**
 * Get property from user
 */
-(void) user_custom_property:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command
                           expecting:@[[NSString class]]
                           withBlock:^id(NSArray *args){
                               MOCAInstance *instance = [MOCA currentInstance];
                               if(!instance) {
                                   return [self returnErrorInstanceNotAvailableForCallbackId:command.callbackId];
                               }
                               MOCAUser *user = [instance currentUser];
                               if(!user) {
                                   return [self errorPluginResultWithMessage:@"User is no longer logged in, cannot get property"];
                               }
                               NSString *key = args[0];
                               return @{key: [user valueForProperty:key]};
                           }];
}

-(void) is_user_logged_in:(CDVInvokedUrlCommand*)command {
    [self performCallbackWithCommand:command
                           expecting:nil
                           withBlock:^id(NSArray *args){
                               MOCAInstance *instance = [MOCA currentInstance];
                               if(!instance) {
                                   return [self returnErrorInstanceNotAvailableForCallbackId:command.callbackId];
                               }
                               MOCAUser *user = [instance currentUser];
                               return @(user != nil);
                           }];
}

-(void) stashEventCommand:(CDVInvokedUrlCommand*)command {
    MOCA_LOG_DEBUG(@"stashing event command");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.eventsDelegate addCommand:command];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) stashActionCommand:(CDVInvokedUrlCommand*)command {
    MOCA_LOG_DEBUG(@"stashing action command");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.actionsDelegate addCommand:command];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma events
-(void) enterBeacon:(CDVInvokedUrlCommand*)command {
    [self stashEventCommand:command];
}
-(void) exitBeacon:(CDVInvokedUrlCommand*)command {
    [self stashEventCommand:command];
}
-(void) beaconProximityChange:(CDVInvokedUrlCommand*)command {
    [self stashEventCommand:command];
}
-(void) enterPlace:(CDVInvokedUrlCommand*)command {
    [self stashEventCommand:command];
}
-(void) exitPlace:(CDVInvokedUrlCommand*)command {
    [self stashEventCommand:command];
}
-(void) enterZone:(CDVInvokedUrlCommand*)command {
    [self stashEventCommand:command];
}
-(void) exitZone:(CDVInvokedUrlCommand*)command {
    [self stashEventCommand:command];
}
-(void) didLoadedBeaconsData:(CDVInvokedUrlCommand*)command {
    [self stashEventCommand:command];
}

#pragma actions
-(void) customAction:(CDVInvokedUrlCommand*)command {
    [self stashActionCommand:command];
}
-(void) displayAlert:(CDVInvokedUrlCommand*)command {
    [self stashActionCommand:command];
}
-(void) openUrl:(CDVInvokedUrlCommand*)command {
    [self stashActionCommand:command];
}
-(void) showEmbeddedHtml:(CDVInvokedUrlCommand*)command {
    [self stashActionCommand:command];
}
-(void) playVideo:(CDVInvokedUrlCommand*)command {
    [self stashActionCommand:command];
}
-(void) showImage:(CDVInvokedUrlCommand*)command {
    [self stashActionCommand:command];
}
-(void) addPassbook:(CDVInvokedUrlCommand*)command {
    [self stashActionCommand:command];
}
-(void) addTag:(CDVInvokedUrlCommand*)command {
    [self stashActionCommand:command];
}
-(void) playSound:(CDVInvokedUrlCommand*)command {
    [self stashActionCommand:command];
}

#pragma other functions

-(void)placesInside:(CDVInvokedUrlCommand *)command
{
    NSArray *places = [[MOCA proximityService] places];
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (MOCAPlace *place in places) {
        if ([place currentState] == CLRegionStateInside) {
            [messages addObject:[MOCAPluginCallbackMessage messageWithPlace:place]];
        }
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:messages];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma other helpers

- (BOOL)checkInitied:(CDVInvokedUrlCommand*)command {
    if(!MOCA.initialized) {
        [self failWithCallbackId:command.callbackId andMessage:@"MOCA SDK is not running."];
        return NO;
    }
    return YES;
}

-(NSError *) returnErrorInstanceNotAvailableForCallbackId: (NSString *) callbackId {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: @"MOCA Instance is not available",
                               NSLocalizedFailureReasonErrorKey: @"MOCA SDK failure or SDK is not initialized",
                               NSLocalizedRecoverySuggestionErrorKey: @"Ensure SDK is initialized, or contact support"
                               };
    return [NSError errorWithDomain:@"MocaSDK" code:1 userInfo:userInfo];
}

@end

