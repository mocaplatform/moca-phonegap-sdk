//
//  MOCAPluginEventsDelegate.h
//  HelloCordova
//
//  Created by David Gonzalez Shannon on 16/12/15.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "MOCA.h"
#import "MOCAProximityDelegate.h"
#import "MOCAPluginCallbackMessage.h"
#import "MOCAPluginConstants.h"

@interface MOCAPluginEventsDelegate : NSObject <MOCAProximityEventsDelegate>

@property (nonatomic, strong) id<MOCAProximityEventsDelegate> defaultDelegate;
@property (nonatomic, strong) id<CDVCommandDelegate> commandDelegate;

+(MOCAPluginEventsDelegate *) withCommandDelegate:(id<CDVCommandDelegate>)commandDelegate;

-(void)addCommand:(CDVInvokedUrlCommand*)command;

@end
