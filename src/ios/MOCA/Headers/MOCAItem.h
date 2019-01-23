//
//  MOCAItem.h
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
 * MOCA item represents an immutable object that can be viewed or purchased by a User.
 * The item has an unique identifier @itemId and a collection of properties
 * that describe its unit price, currency, and the category this item belongs to.
 */
@protocol MOCAItem

/**
 * @return The item identifier
 */
@property (readonly) NSString * itemId;

/**
 * @return the price of a single item unit
 */
@property (readonly) double unitPrice;

/**
 * @return currency 3-letter ISO code or name of virtual currency that
 * is used to give the price.
 */
@property (readonly) NSString * currency;

/**
 * @return The category of this item
 */
@property (readonly) NSString * category;


@end

