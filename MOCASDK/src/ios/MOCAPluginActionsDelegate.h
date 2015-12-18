//
//  MOCAPluginActionsDelegate.h
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

@interface MOCAPluginActionsDelegate : NSObject <MOCAProximityActionsDelegate>

@property (nonatomic, strong) id<MOCAProximityActionsDelegate> defaultDelegate;
@property (nonatomic, strong) id<CDVCommandDelegate> commandDelegate;

+(MOCAPluginActionsDelegate *) delegateWithDefault:(id<MOCAProximityActionsDelegate>)defaultDelegate
                                andCommandDelegate:(id<CDVCommandDelegate>)commandDelegate;


-(void)addCommand:(CDVInvokedUrlCommand*)command;

@end
