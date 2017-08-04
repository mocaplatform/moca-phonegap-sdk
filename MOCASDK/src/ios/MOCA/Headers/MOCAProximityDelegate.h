
//
//  MOCAProximityDelegate.h
//
//  MOCA iOS SDK
//
//  This module is part of InnoQuant MOCA Platform.
//
//  Copyright (c) 2015-2016 InnoQuant Strategic Analytics, S.L.
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
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#include <AvailabilityMacros.h>
#include "MOCAAction.h"

@class MOCAProximityService;
@class MOCABeacon;
@class MOCAZone;
@class MOCAPlace;
@class MOCAExperience;
@class MOCAAction;
@class MOCALabel;

/**
 * Protocol defines the delegate methods to respond to proximity-related events.
 * All methods are optional.
 */
NS_CLASS_AVAILABLE(NA, 7_0)
@protocol MOCAProximityEventsDelegate <NSObject>

@optional

/**
 * Method triggered when iOS device detects a new beacon.
 *
 * @param service proximity service
 * @param beacon MOCA beacon
 *
 */
-(void)proximityService:(MOCAProximityService*)service
          didEnterRange:(MOCABeacon *)beacon
          withProximity:(CLProximity)proximity;

/**
 * Method triggered when iOS device lost the connection to previously detected beacon.
 *
 * @param service proximity service
 * @param beacon MOCA beacon
 *
 */
-(void)proximityService:(MOCAProximityService*)service
          didExitRange:(MOCABeacon *)beacon;


/**
 * Method triggered when the state of a beacon proximity did changed.
 *
 * @param service proximity service
 * @param beacon MOCA beacon
 * @param prevProximity - previous beacon proximity state
 * @param curProximity - current beacon proximity state
 *
 */
-(void)proximityService:(MOCAProximityService*)service
    didBeaconProximityChange:(MOCABeacon*)beacon
               fromProximity:(CLProximity)prevProximity
                 toProximity:(CLProximity)curProximity;

/**
 * Method triggered when iOS device did entered a place.
 *
 * @param service proximity service
 * @param place MOCA place
 *
 */
-(void)proximityService:(MOCAProximityService*)service
          didEnterPlace:(MOCAPlace *)place;

/**
 * Method triggered when iOS device did exit place.
 *
 * @param service proximity service
 * @param place MOCA place
 *
 */
-(void)proximityService:(MOCAProximityService*)service
          didExitPlace:(MOCAPlace *)place;

/**
 * Method triggered when iOS device did entered a specific zone of a place.
 *
 * @param service proximity service
 * @param zone MOCA zone
 *
 */
-(void)proximityService:(MOCAProximityService*)service
           didEnterZone:(MOCAZone *)zone;

/**
 * Method triggered when iOS device did exit a specific zone of a place.
 *
 * @param service proximity service
 * @param zone MOCA zone
 *
 */
-(void)proximityService:(MOCAProximityService*)service
           didExitZone:(MOCAZone *)zone;

/**
 * Method triggered when iOS device did entered a labeled region.
 *
 * @param service proximity service
 * @param label MOCA label
 *
 */
-(void)proximityService:(MOCAProximityService*)service
          didEnterLabel:(MOCALabel*)label;

/**
 * Method triggered when iOS device did exit a labeled region.
 *
 * @param service proximity service
 * @param label MOCA label
 *
 */
-(void)proximityService:(MOCAProximityService*)service
            didExitLabel:(MOCALabel* )label;


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
            handleCustomTrigger:(NSString*)customAttribute;


/**
 * Method invoked when a proximity service loaded or updated a registry of beacons
 * from MOCA cloud.
 *
 * @param service proximity service
 * @param beacons current collection of registered beacons
 *
 */
-(void)proximityService:(MOCAProximityService*)service
   didLoadedBeaconsData:(NSArray*)beacons;

@end


/**
 * Type of context when an action if fired.
 *
 * Actions can be fired in two situations:
 * - when proximity trigger (beacon/geofence) fires
 * - when a user clicks on a push notification with an associated action
 */
typedef NS_ENUM(NSInteger, MOCAFireSituation) {
    // Indicates that an action is fired automatically by a proximity trigger
    // when the app is foreground or background.
    MOCAFiredByProximity,
    // Indicates that an action is fired by a user clicking a push notification
    // generated previously by proximity action fired in background.
    MOCAFiredByPushClicked
};

/**
 * Protocol defines the delegate methods to respond to proximity-invoked actions.
 * All methods are optional.
 */
NS_CLASS_AVAILABLE(NA, 7_0)
@protocol MOCAProximityActionsDelegate <NSObject>

@optional

/**
 * Called to determine if a specific proximity action can be executed now.
 *
 * Discussion
 *
 * It is typically implemented by the hosting app that wants to control
 * when the experiences should be displayed and when not.
 * 
 * Example
 *
 * An app that displays a splash screen may want to enable proximity actions
 * to be displayed only after displaying the home screen.
 */
-(BOOL)actionCanDisplayNow:(MOCAAction*)sender withSituation:(MOCAFireSituation)situation;

/**
 * Called when action if fired and accepted by actionCanDisplayNow() method.
 * This method is invoked for all action types and should be used to perform generic action logic.
 * @return YES if action execution flow should proceed, or NO otherwise.
 */
-(BOOL)action:(MOCAAction*)sender withSituation:(MOCAFireSituation)situation;

/**
 * Called when an alert notification should be displayed to a user.
 * @param alertMessage a simple string to be displayed as an alert
 * @return YES if the alert was shown to the user, NO otherwise.
 */
-(BOOL)action:(MOCAAction*)sender displayNotificationAlert:(NSString *)alertMessage withSituation:(MOCAFireSituation)situation;

/*
 * Called when a URL content should be displayed to a user.
 * @param url a content URL to be displayed
 * @return YES if the alert was shown to the user, NO otherwise.
 */
-(BOOL)action:(MOCAAction*)sender openUrl:(NSURL*)url withSituation:(MOCAFireSituation)situation;

/*
 * Called when a embedded HTML content should be displayed to a user.
 * @param html a HTML content to be displayed
 * @return YES if the alert was shown to the user, NO otherwise.
 */
-(BOOL)action:(MOCAAction*)sender showHtmlWithString:(NSString*)html withSituation:(MOCAFireSituation)situation;

/*
 * Called when a video from URL should be played to a user.
 * @param url - video content URL
 * @return YES if the alert was shown to the user, NO otherwise.
 */
-(BOOL)action:(MOCAAction*)sender playVideoFromUrl:(NSURL*)url withSituation:(MOCAFireSituation)situation;

/*
 * Called when an image from URL should be displayed to a user.
 * @param url - image URL
 * @return YES if the alert was shown to the user, NO otherwise.
 */
-(BOOL)action:(MOCAAction*)sender displayImageFromUrl:(NSURL*)url withSituation:(MOCAFireSituation)situation;

/*
 * Called when a Passbook pass card from URL should be displayed to a user.
 * @param url - pass URL
 * @return YES if the alert was shown to the user, NO otherwise.
 */
-(BOOL)action:(MOCAAction*)sender displayPassFromUrl:(NSURL*)url withSituation:(MOCAFireSituation)situation;

/*
 * Called when a user should be tagged.
 * @param tagName name of the tag
 * @param value value to be added
 * @return YES if the tag should be added to user profile, NO otherwise.
 */
-(BOOL)action:(MOCAAction*)sender addTag:(NSString*)tagName withValue:(NSString*)value;

/*
 * Called when a sound notification should be played.
 * @param soundFilename The sound file to play or `default` for the standard notification sound.
 * This file must be included in the application bundle or available in system bundle.
 * @return YES if the alert was shown to the user, NO otherwise.
 */
-(BOOL)action:(MOCAAction*)sender playNotificationSound:(NSString *)soundFilename withSituation:(MOCAFireSituation)situation;

/*
 * Called when the app should execute a custom action.
 * @param customAttribute - user provided custom attribute
 * @return YES if the alert was shown to the user, NO otherwise.
 */
-(BOOL)action:(MOCAAction*)sender performCustomAction:(NSString*)customAttribute withSituation:(MOCAFireSituation)situation;

/** 
 * Called to customize the app root view that should be used to display overlay popup window.
 * @param superview - default superview to add the overlay to as a child view.
 * @return selected view to be used as superview.
 */
-(UIView*)willShowOverlayInView:(UIView*) superview;

@end



