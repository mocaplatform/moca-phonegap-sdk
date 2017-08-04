//
//  MOCARecoClient.h
//
//  MOCA iOS SDK
//
//  This module is part of InnoQuant MOCA Platform.
//
//  Copyright (c) 2012-2016 InnoQuant Strategic Analytics, S.L.
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

// ----------------------------------------------------------------------------------------------------


typedef NS_ENUM(NSInteger, MOCARecoMethod) {
    
    /**
     * Uses random items to generate recommendations.
     */
    Random = 0,
    
    /**
     * Uses most frequently visited items by community to generate recommendations.
     */
    TopTrends = 1,
    
    /**
     * Uses machine-learnt recommendation models to personalize recommendations
     */
    ItemSimilarity = 2
};

// ----------------------------------------------------------------------------------------------------

#pragma mark MOCARecoItem

/**
 * MOCA recommended item.
 */
@interface MOCARecoItem : NSObject

/**
 * @return recommended item identifier (unique within recommended category)
 */
@property (readonly) NSString * itemId;

/**
 * @return recommended item name (optional, only available if recommendations resolved flag = YES)
 */
@property (readonly) NSString * name;

/**
 * @return recommendation score
 */
@property (readonly) double score;

/**
 * @return recommended item index in the recommendation list
 */
@property (readonly) int index;

@end

#pragma mark


// ----------------------------------------------------------------------------------------------------

#pragma mark MOCAItemList

/**
 * Identifier List enables you to manage list of items: WhiteList or BlackLists.
 */
@interface MOCAItemList : NSObject

/**
 * List size
 */
@property (readonly) int size;

/*
 * Returns YES if the list is empty.
 */
@property (readonly, getter=isEmpty) BOOL empty;

/**
 * Adds a new item identifier to the list.
 */
- (void) add:(NSString *) itemId;

/**
 * Removes an item from the list.
 */
- (void) remove:(NSString *) itemId;
/**
 * Checks if the item is contained in the list.
 */
- (BOOL) contains:(NSString *) itemId;
/**
 * Clears the list
 */
- (void) clear;

@end


#pragma mark


// ----------------------------------------------------------------------------------------------------

#pragma mark MOCABoostList

/**
 * BoostList enables you to enforce items to return in the recommendation results.
 */
@interface MOCABoostList : NSObject

/**
 * List size
 */
@property (readonly) int size;

/*
 * Returns YES if the list is empty.
 */
@property (readonly, getter=isEmpty) BOOL empty;

/**
 * Adds a new item identifier to the list.
 */
- (void) add:(NSString *) itemId withBoost:(NSNumber*)boost;

/**
 * Removes an item from the list.
 */
- (void) remove:(NSString *) itemId;

/**
 * Get item boost from the list.
 */
- (NSNumber*) boostForItemId:(NSString *) itemId;

/**
 * Checks if the item is contained in the list.
 */
- (BOOL) contains:(NSString *) itemId;
/**
 * Clears the list
 */
- (void) clear;

@end

#pragma mark


// ----------------------------------------------------------------------------------------------------

#pragma mark MOCARecoFilters

/**
 * Recommender filters
 */
@interface MOCARecoFilters : NSObject

/**
 * Enables/disabled location-based recommendations.
 */
@property (readwrite, nonatomic) BOOL locationEnabled;

/*
 * Enables/disabled time-based recommendations.
 */
@property (readwrite) BOOL timeEnabled;

@end

#pragma mark

// ----------------------------------------------------------------------------------------------------

#pragma mark MOCARecoClient

@protocol MOCARecoDelegate;

/**
 * MOCARecoClient is a recommender of items of a specific category, e.g. exhibitors.
 * The client encapsulates MOCA Recommendation Client API.
 *
 * A single client provides user personalized recommendations on a specific category
 * such as exhibitors, sessions, speakers or products. This client becomes
 * active once created and until it is explicitely closed. While active,
 * this recommender will automatically synchronize current user recommendations
 * with the cloud. The synchronization process is automatic, but the app
 * can trigger manual update using updateAsync method. The automatic updates
 * are triggered by various events including background fetch, location updates,
 * client configuration changes, scheduled timer events and others. The updates
 * are performed both in foreground and background modes.
 *
 * Additionally, this client tracks current user changes reflected by MOCA User API.
 * (log-in, log-out events). To provide personalized recommendations, this client
 * maintains persistent state for each individual user on local storage.
 * When a new user logs in, its previous state is restored from local storage
 * and then updated with the cloud. Therefore, this client can be used to
 * provide both online and offline recommendations anytime.
 *
 * An app can use multiple clients to provide recommendations of various categories.
 */
@interface MOCARecoClient: NSObject

/**
 * The user identifier. In "anonymous mode" (no user logged-in), returns nil.
 * This identifier will change, if the current users is logged out or a new
 * user is logged-in.
 */
@property (readonly) NSString *userId;

/**
 * Returns YES if user is logged-in, FALSE for anonymous mode.
 */
@property (readonly, getter=isLoggedIn) BOOL logged;

/**
 * Category of items recommended by this client.
 */
@property (readonly) NSString *category;

/**
 * Black List enables you to manage a list of items excluded from recommendations
 * for the current user. Defaults to empty list.
 *
 * This list is automatically persisted to local storage individually for
 * each user.
 */
@property (readonly) MOCAItemList *blackList;

/**
 * White List enables you to manage a list of items that can only be suggested as
 * recommendations for the current user. By default list is empty and
 * all items are permitted.
 *
 * This list is automatically persisted to local storage individually for
 * each user.
 */
@property (readonly) MOCAItemList *whiteList;

/**
 * Boost List enables you to modify (boost) scores of particular items
 * for current user. Boost acts as a multiplier to recommendation scores.
 * Defaults to empty list.
 *
 * This list is persistent per user.
 */
@property (readonly) MOCABoostList *boostList;

/**
 * The maximum number of items that can recommended for current user in a single query.
 * Persistent per user.
 */
@property (readwrite) int maxRecommendations;

/**
 * The minimum interval (in milliseconds) before new recommendations are
 * fetched from cloud. Defaults to 1 hour. Persistent per user.
 *
 * This interval is used as a hint by the recommender rather than a hard limit.
 * In many situations, recommender uses heuristics to determine exact
 * synchronization intervals.
 */
@property (readwrite) int minUpdateInterval;

/**
 * Filters to be applied to user recommendations. Persistent per user.
 */
@property (readonly) MOCARecoFilters *filters;

/**
 * Desired recommendation method used by this recommender. Persistent per user.
 * Defaults to ItemsSimilarity method.
 *
 * The method is used as a hint by the recommender. In some circumstances,
 * such as new users without historical data, the recommender may choose
 * a different method as a best available choice.
 */
@property (readwrite) MOCARecoMethod recoMethod;

/**
 * Indicates the recommender to obtain names of recommended items.
 * Defaults to false. Persistent per user.
 */
@property (readwrite) BOOL resolve;

/**
 * Delegate protocol user to receive recommender events.
 */
@property (readwrite) id<MOCARecoDelegate> delegate;

/**
 * Begins immediate update of recommendations for the current user.
 * This method is asynchronous and begins the remote fetch operation
 * of new recommendations from the cloud.
 *
 * When Internet connection is not available (or data transmission is limited
 * to WifiOnly mode), this call schedules the update to be performed at
 * a later time.
 *
 * Note: Usually, this method is called automatically by this recommender
 * when a user starts a new session, there is a significant location change
 * for location-based recommendations, or before local recommendations expire.
 */
-(void) updateAsync;

/**
 * Retrieve list of latest recommendations for current user of up to @limit items.
 *
 * This method is synchronous and returns immediately. You may safely call
 * this method multiple times without incurring any overhead. The returned
 * results are updated asynchronously in a periodic fashion.
 *
 * On cold start, it is possible this method returns an empty list, when
 * the recommendations has not yet been retrieved from the cloud.
 * After restarting the app, the method returned latest recommendations
 * that has been previously stored in a local storage and for a specific user.
 *
 * @param limit - maximum number of items in the returned list
 *
 * @return ordered list of recommendations
 */
-(NSArray<MOCARecoItem*> *) recommendationsWithLimit: (int) limit;

/**
 * Track view item event. You call this method to notify the recommender
 * that user has viewed an item.
 *
 * @param itemId - id of a viewed item
 * @param recommended - YES if user viewed a recommended item, NO otherwise.
 *
 * @exception NSInvalidArgumentException
 */
-(void) trackViewItem: (NSString*) itemId wasRecommended:(BOOL) recommended;

/**
 * Track like/unlike item event. You call this method to notify the recommender
 * that user has liked/unliked an item.
 *
 * @param itemId - id of a viewed item
 * @param liked - YES if liked, NO if not liked anymore.
 *
 * @exception NSInvalidArgumentException
 */
-(void) trackLikeItem: (NSString*) itemId liked: (BOOL) liked;


/**
 * Track buy item event. You call this method to notify the recommender
 * that user has purchased an item.
 *
 * @param itemId - id of a purchased item
 * @param count - quantity of items purchased
 * @param price - single item price
 * @param recommended - YES if user bougth a recommended item, NO otherwise.
 *
 * @exception NSInvalidArgumentException
 */

-(void) trackBuyItem: (NSString *) itemId
       numberOfItems: (int) count
     singleItemPrice: (double) price
         wasRecommended: (BOOL) recommended;

/**
 * Closes the client and shuts down all underlying services.
 * Only call this method to shutdown recommendations for a specific category.
 *
 * Once called, all those recommenations will not be automatically updated anymore.
 */
-(void) close;

@end



#pragma mark MOCARecoDelegate

/**
 * MOCA Recommender delegate
 */
@protocol MOCARecoDelegate <NSObject>

/**
 * Called when recommendations for current user has been updated.
 * @param client
 */
@optional
-(void) recoClientDidUpdate: (MOCARecoClient *) client;

/**
 * Called when user logged-in or logged-out
 * @param client
 */
@optional
-(void) recoClient: (MOCARecoClient *) client didChangeUser: (NSString *) userId;

/**
 * Called when recommender cloud operation failed
 * @param client
 * @param errorCode - error code
 * @param message - error message
 */
@optional
-(void) recoClient: (MOCARecoClient *) client didFailWithError:(NSError*) error;

/**
 * Called when recommender has been closed.
 * @param client
 */
@optional
-(void) recoClientDidClose: (MOCARecoClient *) client;

@end

    

    
