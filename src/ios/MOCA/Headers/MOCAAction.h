//
//  MOCAAction.h
//
//  MOCA iOS SDK
//
//  This module is part of InnoQuant MOCA Platform.
//
//  Copyright (c) 2015 InnoQuant Strategic Analytics, S.L.
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

/**
 * The MOCAAction class represents an action invoked by a proximity context.
 *
 * MOCAAction class contains basic properties that describe the action to be performed.
 *
 * @see MOCAProximityService
 */
@interface MOCAAction : NSObject

/**
 * Returns id of associated proximity experience.
 */
@property (readonly) NSString *identifier;
/**
 * Textual description of this Action
 */
@property (readonly) NSString *caption;
/**
 * Textual description of content of this Action
 */
@property (readonly) NSString *content;
/**
 * Textual description of content to be delivered to user
 * when the app is in background in form of a local notification.
 */
@property (readonly) NSString *backgroundAlert;

@end
