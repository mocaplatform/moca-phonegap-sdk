//
//  MOCAZone.h
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

#import "MOCAPropertyContainer.h"
#import "MOCAPlace.h"
#import "MOCALabel.h"
#import "MOCARegion.h"

/**
 * Proximity zone that is used to group a set of beacons.
 */
NS_CLASS_AVAILABLE(NA, 7_0)
@interface MOCAZone : MOCAPropertyContainer <MOCARegion>

/**
 * Zone identifier. Globally unique.
 */
@property(readonly, nonatomic, strong) NSString *identifier;

/**
 * Zone name.
 */
@property(readonly, nonatomic, strong) NSString *name;

/**
 * Zone category.
 */
@property(readonly, nonatomic, copy) NSString *category;

/**
 * Zone provider
 */

@property(readonly, nonatomic, strong) NSString *provider;
/**
 * Zone short id. Unique inside a place and floor number.
 */
@property(readonly, nonatomic, copy) NSString *shortId;

/**
 * Floor number this zone is located at. Defaults 0.
 */
@property(readonly, nonatomic) NSNumber *floorNumber;

/**
 * Place this zone is assigned to.
 */
@property(readonly, nonatomic) MOCAPlace *place;

/**
 * A collection of beacons registered within this zone.
 */
@property(readonly, nonatomic, retain) NSArray *beacons;

/**
 * Zone labels.
 */
@property(readonly, nonatomic) NSSet<MOCALabel *> *labels;

/*
 * Represents the previous state of the device with reference to a zone.
 *
 * @return CLRegionStateInside if a user was in zone range, CLRegionStateOutside when
 * it was outside the zone range, otherwise returns CLRegionStateUnknown.
 */
@property(readonly, nonatomic) CLRegionState previousState;

/*
 * Represents the current state of the device with reference to a zone.
 *
 * @return CLRegionStateInside if a user is in zone range, CLRegionStateOutside when
 * it is outside the zone range, otherwise returns CLRegionStateUnknown.
 */
@property(readonly, nonatomic) CLRegionState currentState;

/**
 * Returns YES if its location data is valid (e.g beacon engine is running)
 */
@property(readonly, getter=isRegionDataValid) BOOL regionDataValid;

@property(nonatomic) BOOL justWentOutside;

- (int)beaconsInRange;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToZone:(MOCAZone *)zone;

- (NSUInteger)hash;

@end
