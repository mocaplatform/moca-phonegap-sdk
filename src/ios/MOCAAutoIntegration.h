//
//  MOCAAutoIntegration.h
//  MOCAPlugin
//
//  Created by Iván González on 12/10/16.
//
//

#import <Foundation/Foundation.h>
#import "MOCAPlugin.h"
#ifdef IS_IOS10_OR_GREATER
#import "MOCAPluginNotificationsDelegate.h"
#endif


@interface MOCAAutoIntegration : NSObject

#ifdef IS_IOS10_OR_GREATER
+ (void) autoIntegrateWithNotificationsDelegate:(MOCAPluginNotificationsDelegate *) delegate;
#else
+ (void) autoIntegrateWithNotificationsDelegate:(id) delegate;
#endif

@end
