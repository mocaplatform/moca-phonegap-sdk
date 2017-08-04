//
//  IndoorLocationTracker.h
//  MocaSDK
//
//  Created by Iván González on 2/9/16.
//  Copyright © 2016 InnoQuant. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MOCASensorErrorDelegate;
@protocol MOCAIndoorDelegate;
@class NaoManager;
@class CLLocation;


typedef NS_ENUM(NSInteger, MOCAIndoorError) {
    GenericError,
    InvalidPlaceConfiguration,
    UnsupportedOS
};

typedef NS_ENUM(NSInteger, MOCAIndoorWarning) {
    LocationTemporaryUnavailable,
    SyncError,
    NoLocationPermission,
    BleNotEnabled,
    WifiNotEnabled,
    RequiresCompassCalibration,
    NoIndoorData
};

@class MOCAIndoorClient;
@class MocaNaoListenersBridge;
@protocol MOCAIndoorDelegate <NSObject>

/**
 * Once the device is inside an indoor-enabled building, location engine will report user's position
 * once every ~1 sec
 */
@required
- (void)indoorClient:(MOCAIndoorClient *)client didUpdateToLocation:(CLLocation *) location;
@optional

/**
 * Called when a fatal error prevented location engine from starting
 */
- (void) didFailWithError:(MOCAIndoorError) error message:(NSString*) message;

/**
 * Called when a non fatal error has arised
 */
- (void) didReceiveWarning: (MOCAIndoorWarning) warning message:(NSString*) message;

/**
 * Called when sync succesfully finishes
 */
- (void) didSynchronizeClient: (MOCAIndoorClient*) client;

@end


@interface MOCAIndoorClient : NSObject

@property (readwrite, nonatomic) id <MOCASensorErrorDelegate> sensorDelegate;
/**
 * Start the indoor location engine
 */
- (void) start;

/**
 * Stop the indoor location engine
 */
- (void) stop;

/**
 * Sync with cloud (it is recommended to have the files locally stored)
 */
- (void) sync;

/**
 * Call this method when you no longer need the location engine
 */
- (void) close;

@end
