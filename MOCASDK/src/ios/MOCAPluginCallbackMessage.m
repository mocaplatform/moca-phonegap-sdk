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
    
    NSDictionary *detail = @{
        @"name":beacon.name,
        @"proximity": [self stringForProximity:beacon.proximity],
        @"timestamp": [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]],
        @"type": @"beacon"
    };
    
    return @{ @"detail": detail };
}

+(NSDictionary *)messageWithPlace:(MOCAPlace *)place
{
    NSDictionary *detail = @{
        @"id":place.identifier,
        @"geofence": @{
            @"lat": [NSNumber numberWithDouble: place.geofence.center.latitude],
            @"lon": [NSNumber numberWithDouble: place.geofence.center.longitude]
        },
        @"name":place.name,
        @"timestamp": [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]],
        @"type": @"place"
    };
    
    return @{ @"detail": detail };
}

+(NSDictionary *)messageWithZone:(MOCAZone *)zone
{
    NSDictionary *detail = @{
        @"name":zone.name,
        @"timestamp": [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]],
        @"type": @"zone",
        @"id": zone.identifier
    };
    
    return @{ @"detail": detail };
}

+(NSDictionary *)message:(id)message forAction:(NSString *)action
{
    return @{
         @"detail": @{
              action: message
         }
    };
}

@end
