//
//  MOCAPluginCallbackMessage.m
//  HelloCordova
//
//  Created by David Gonzalez Shannon on 17/12/15.
//
//

#import "MOCAPluginCallbackMessage.h"

@implementation MOCAPluginCallbackMessage

// Missing Data

// - beaconID
// - Geofence Accuracy

+(NSString *)stringForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:    return @"Unknown";
        case CLProximityFar:        return @"Far";
        case CLProximityNear:       return @"Near";
        case CLProximityImmediate:  return @"Immediate";
        default:
            return nil;
    }
}

+(NSDictionary *)messageWithBeacon:(MOCABeacon *)beacon
{
    NSDictionary *details = @{
        @"major":beacon.major,
        @"minor":beacon.minor,
        @"name":beacon.name,
        @"proximity": [self stringForProximity:beacon.proximity],
        @"timestamp": [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]],
        @"type": @"beacon",
        @"uuid": [beacon.proximityUUID UUIDString]
    };
    
    return @{ @"details": details };
}

+(NSDictionary *)messageWithPlace:(MOCAPlace *)place
{
    NSDictionary *details = @{
        @"id":place.identifier,
        @"geofence": @{
            @"lat": [NSNumber numberWithDouble: place.geofence.center.latitude],
            @"lon": [NSNumber numberWithDouble: place.geofence.center.longitude]
        },
        @"name":place.name,
        @"timestamp": [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]],
        @"type": @"place"
    };
    
    return @{ @"details": details };
}

+(NSDictionary *)messageWithZone:(MOCAZone *)zone
{
    NSDictionary *details = @{
        @"name":zone.name,
        @"timestamp": [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]],
        @"type": @"zone",
        @"id": zone.identifier
    };
    
    return @{ @"details": details };
}

+(NSDictionary *)message:(NSString *)message forAction:(NSString *)action
{
    return @{
         @"details": @{
              action: message
         }
    };
}

@end
