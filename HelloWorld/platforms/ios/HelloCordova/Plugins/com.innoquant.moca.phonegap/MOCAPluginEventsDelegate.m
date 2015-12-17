//
//  MOCAPluginEventsDelegate.m
//  HelloCordova
//
//  Created by David Gonzalez Shannon on 16/12/15.
//
//

#import "MOCAPluginEventsDelegate.h"

@interface MOCAPluginEventsDelegate()

@property (nonatomic, retain)NSDictionary *commands;

@end

@implementation MOCAPluginEventsDelegate


+(MOCAPluginEventsDelegate *) delegateWithDefault:(id<MOCAProximityEventsDelegate>)defaultDelegate
                               andCommandDelegate:(id<CDVCommandDelegate>)commandDelegate
{
    MOCAPluginEventsDelegate *delegate = [[MOCAPluginEventsDelegate alloc] init];
    delegate.defaultDelegate = defaultDelegate;
    delegate.commandDelegate = commandDelegate;
    return delegate;
}

-(NSDictionary*)commands {
    if (!_commands) {
        _commands = [[NSDictionary alloc] init];
    }
    return _commands;
}

-(void)addCommand:(CDVInvokedUrlCommand*)command
{
    [self.commands setValue:command forKey:command.methodName];
}

-(void)sendResultWithBeacon:(MOCABeacon*)beacon andCommand:(CDVInvokedUrlCommand*)command
{
    NSDictionary *message = [MOCAPluginCallbackMessage messageWithBeacon:beacon];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)sendResultWithZone:(MOCAZone*)zone andCommand:(CDVInvokedUrlCommand*)command
{
    NSDictionary *message = [MOCAPluginCallbackMessage messageWithZone:zone];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)sendResultWithPlace:(MOCAPlace*)place andCommand:(CDVInvokedUrlCommand*)command
{
    NSDictionary *message = [MOCAPluginCallbackMessage messageWithPlace:place];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

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
    CDVInvokedUrlCommand *command = [self.commands objectForKey:@"didEnterRange"];
    if(command) {
        [self sendResultWithBeacon:beacon andCommand:command];
        MOCA_LOG_DEBUG(@"didEnterRange custom handler");
    } else {
        [self.defaultDelegate proximityService:service didEnterRange:beacon withProximity:proximity];
    }
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
    CDVInvokedUrlCommand *command = [self.commands objectForKey:@"didExitRange"];
    if(command) {
        [self sendResultWithBeacon:beacon andCommand:command];
        MOCA_LOG_DEBUG(@"didExitRange custom handler");
    } else {
        [self.defaultDelegate proximityService:service didExitRange:beacon];
    }
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
    CDVInvokedUrlCommand *command = [self.commands objectForKey:@"didBeaconProximityChange"];
    if(command) {
        [self sendResultWithBeacon:beacon andCommand:command];
        MOCA_LOG_DEBUG(@"didBeaconProximityChange custom handler");
    } else {
        [self.defaultDelegate proximityService:service didBeaconProximityChange:beacon fromProximity:prevProximity toProximity:curProximity];
    }
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
    id command = [self.commands objectForKey:@"didEnterPlace"];
    if(command) {
        [self sendResultWithPlace:place andCommand:command];
        MOCA_LOG_DEBUG(@"didEnterPlace custom handler");
    } else {
        [self.defaultDelegate proximityService:service didEnterPlace:place];
    }
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
    id command = [self.commands objectForKey:@"didExitPlace"];
    if(command) {
        [self sendResultWithPlace:place andCommand:command];
        MOCA_LOG_DEBUG(@"didExitPlace custom handler");
    } else {
        [self.defaultDelegate proximityService:service didExitPlace:place];
    }
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
    id command = [self.commands objectForKey:@"didEnterZone"];
    if(command) {
        [self sendResultWithZone:zone andCommand:command];
        MOCA_LOG_DEBUG(@"didEnterZone custom handler");
    } else {
        [self.defaultDelegate proximityService:service didEnterZone:zone];
    }
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
    id command = [self.commands objectForKey:@"didExitZone"];
    if(command) {
        [self sendResultWithZone:zone andCommand:command];
        MOCA_LOG_DEBUG(@"didExitZone custom handler");
    } else {
        [self.defaultDelegate proximityService:service didExitZone:zone];
    }
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
    id command = [self.commands objectForKey:@"handleCustomTrigger"];
    if(command) {
        MOCA_LOG_DEBUG(@"handleCustomTrigger custom handler");
        return YES;
    } else {
        return [self.defaultDelegate proximityService:service handleCustomTrigger:customAttribute];
    }
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
    id command = [self.commands objectForKey:@"didLoadedBeaconsData"];
    if(command) {
        MOCA_LOG_DEBUG(@"didLoadedBeaconsData custom handler");
    } else {
        [self.defaultDelegate proximityService:service didLoadedBeaconsData:beacons];
    }
}

@end