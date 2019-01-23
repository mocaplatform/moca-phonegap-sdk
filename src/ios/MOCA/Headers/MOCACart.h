//
//  MOCACart.h
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
#import "MOCAItem.h"

/**
 * Represents a shopping cart line. Contains a MOCAItem object and quantity.
 */
@interface MOCACartLine : NSObject<MOCASerializable>
    
/**
 * Get the associated item object
 *
 * @return the product
 */
@property (readonly) id<MOCAItem> item;

/**
 * Get quantity of items added to the cart
 *
 * @return number of items
 */
@property (readonly) NSUInteger quantity;

/**
 * Get total line price, i.e. quantity of items by unit price.
 *
 * @return total line price
 */
@property (readonly) double totalPrice;

/**
 * Get timestamp this item has been last updated in the cart.
 *
 * @return timestamp
 */
@property (readonly) NSNumber * modifiedAt;

@end


// ------------------------------------------------------------------------------------------------

/**
 * MOCACart represents a shopping cart that allows a user to place items for eventual purchase.
 */
@interface MOCACart : NSObject<MOCASerializable>

/**
 * Clears the cart.
 */
-(void) clear;

/**
 * Adds or updates a cart item object with specific product item, quantity and price.
 * Cart groups automatically cart items with the same product item, category,
 * currency and unit price. Otherwise, a new cart item is created.
 *
 * @param item    - the item to be added to the cart
 * @param quantity  - number of items
 
 * @return cart item object
 */
-(void) add:(id <MOCAItem>) item withQuantity:(NSUInteger)quantity;

/**
 * Updates the quantity of items in the cart
 *
 * @param itemId - the item identifier
 * @param newQuantity - new quantity
 *
 * @return YES if the item has been updated, NO if it does not exist in the cart.
 */
-(BOOL) update:(NSString*)itemId withQuantity:(NSUInteger)quantity;

/**
 * Removes the item from the cart.
 *
 * @param itemId - the item identifier
 * @return YES if the item has been removed, NO otherwise.
 */
-(BOOL) remove:(NSString*)itemId;

/**
 * Retrieves a list of line items in the cart.
 *
 * @return list of line items.
 */
-(NSArray<MOCACartLine*> *)lines;

/**
 * Returns a cart line object associated with specific @itemId
 * @param itemId - the item identifier
 *
 * @return cart line object, or null otherwise
 */
-(MOCACartLine*) getLine:(NSString*) itemId;

/**
 * Indicates the user has started the checkout operation.
 *
 */
-(BOOL) beginCheckout;

/**
 * Indicates the user has successfully completed the checkout operation.
 * All items has been purchased and the cart has been cleared.
 *
 */
-(BOOL) completeCheckout;

/**
 * Get total price of all items in the cart with specific currency.
 *
 * @return total price in specific currency
 */
-(double) getTotalPrice:(NSString*)currency;

/**
 * Get timestamp this cart has been last updated.
 *
 * @return timestamp
 */
@property (readonly) NSNumber* modifiedAt;

/**
 * Get timestamp this cart has been first created.
 *
 * @return timestamp
 */
@property (readonly) NSNumber* createdAt;

/**
 * Gets number of items in the cart
 *
 * @return number of items
 */
@property (readonly) NSUInteger size;


@end


