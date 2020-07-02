//
// Created by Iván González on 3/5/18.
// Copyright (c) 2018 InnoQuant. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MOCARegion;

@protocol MOCAEventBusEventSubscriber <NSObject>

- (NSString *)subscriberId;
- (void)handleEventForResourceKey:(NSString *)resourceKey;

@end


@interface MOCAEventBus : NSObject

+ (void)publish:(NSString *)eventName;

+ (void)publish:(NSString *)eventName bufferTimeSeconds:(NSTimeInterval)bufferTimeSeconds;

/**
 * Subscribes a class to the Event Bus
 * @param resourceKey the name of the event to be warned about
 * @param subscriber  the listening class
 * @param priority  [0-n] the priority the subscriber will be called, -1 indicates that no priority is requested.
 * The lower the number the higher the priority.
 * Please bear in mind that multiple subscribers can request the same priority for the same event. In those cases
 * the subscribers will be called with in the reverse order they asked the priority (Last In, First Out).
 */
+ (void)subscribeKey:(NSString *)resourceKey
       forSubscriber:(id <MOCAEventBusEventSubscriber>)subscriber
            priority:(int)priority;

+ (void)subscribeKey:(NSString *)resourceKey forSubscriber:(id <MOCAEventBusEventSubscriber>)subscriber;

+ (void)subscribeKeys:(NSArray<NSString *> *)resourceKeys forSubscriber:(id <MOCAEventBusEventSubscriber>)subscriber;

+ (void)unsubscribe:(id <MOCAEventBusEventSubscriber>)subscriber;

+ (void)clear;

@end
