//
//  MOCAItemSet.h
//
//  MOCA iOS SDK
//
//  This module is part of InnoQuant MOCA Platform.
//
//  Copyright (c) 2018 InnoQuant Strategic Analytics, S.L.
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
#import "MOCASerializable.h"

/**
 * Represent persistent collection of items that contains no duplicate elements.
 */
@interface MOCAItemSet : NSObject<MOCASerializable>

/**
 * Clears the collection.
 */
-(void)clear;

/**
 * Adds the specified item to this set if it is not already present (optional operation).
 *
 * @param itemId - item identifier
 * @return true if this set did not already contain the specified item
 */
-(BOOL) add:(NSString*)itemId;

/**
 * Adds all of the items in the specified collection to this set if they're not already present (optional operation).
 *
 * @param itemIds - collection of item identifiers
 * @return true if this set changed as a result of the call
 */
-(BOOL) addAll:(NSArray<NSString*>*)itemIds;

/**
 * Removes the specified item from this set if it is present (optional operation).
 *
 * @param itemId - item identifier
 *
 * @return true if this set contained the specified item
 */
-(BOOL) remove:(NSString*)itemId;

/**
 * Retrieves a list of item identifiers in this set.
 *
 * @return an iterable over the items in this set
 */
-(NSArray<NSString*>*) items;

/**
 * Gets number of items in the set
 *
 * @return number of items
 */
@property (readonly) int size;

/**
 * Get timestamp this item has been last updated in the cart.
 *
 * @return timestamp
 */
@property (readonly) NSNumber * modifiedAt;

/**
 * Get timestamp this item has been first created at.
 *
 * @return timestamp
 */
@property (readonly) NSNumber * createdAt;


@end

