//
//  MOCASegment.h
//
//  MOCA iOS SDK
//
//  This module is part of InnoQuant MOCA Platform.
//
//  Copyright (c) 2016 InnoQuant Strategic Analytics, S.L.
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

/**
 * A segment represents a collection of condtions or criteria, that
 * characterizes a targeted group of users. Usually, a segment is defined 
 * by a query expression over user attributes.
 *
 * For example, all users that speak Spaniash language can be defined
 * by the 'lang=es' query.
 *
 * A user belongs to a specific segment, if her profile meets requested criteria.
 */
@interface MOCASegment : MOCAPropertyContainer

/**
 * Segment identifier.
 */
@property (readonly, nonatomic, copy) NSString * identifier;

/**
 * Segment name (unique to app).
 */
@property (readonly, nonatomic, copy) NSString * name;

/**
 * Date this segment was created.
 */
@property (readonly, nonatomic) NSDate *createdAt;


@end
