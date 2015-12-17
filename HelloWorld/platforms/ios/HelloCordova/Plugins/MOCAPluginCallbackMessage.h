//
//  MOCAPluginCallbackMessage.h
//  HelloCordova
//
//  Created by David Gonzalez Shannon on 17/12/15.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "MOCA.h"
#import "MOCAProximityDelegate.h"

@interface MOCAPluginCallbackMessage : NSObject

+(NSDictionary *)messageWithBeacon:(MOCABeacon *)beacon;
+(NSDictionary *)messageWithPlace:(MOCAPlace *)place;
+(NSDictionary *)messageWithZone:(MOCAZone *)zone;
+(NSDictionary *)message:(id)message forAction:(NSString *)action;
+(NSString *)stringForProximity:(CLProximity)proximity;

@end
