//
// Created by Iván González on 4/5/18.
// Copyright (c) 2018 InnoQuant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, MOCARegionType) {
    Beacon,
    Zone,
    Place,
    Group
};

@protocol MOCARegion <NSObject>

@required
/**
 * Resource identifier
 */
@property(readonly, nonatomic) NSString *identifier;

/**
 * Type + identifier (e.g: Beacon:238jd39d-sda1)
 */
@property(readonly, nonatomic) NSSet<NSString *> * resourceKeys;


/**
 * Return the region provider (Could be a vendor or a region subtype e.g: NAO, Wi-Fi Beacon)
 */
@property(readonly, nonatomic) NSString *provider;

/**
 * Return region name
 */
@property(readonly, nonatomic) NSString *name;

/**
 * Return region type
 */
@property(readonly) MOCARegionType type;

/**
 * Get set of groups associated with this region.
 */
@property(readonly, nonatomic) NSSet *parentGroups;

/**
 * Last known region state
 */
@property(readonly) CLRegionState state;


- (void)addParentGroup:(id<MOCARegion> )parentRegion;


@end
