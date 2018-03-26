//
//  MOCAPluginActionsDelegate.m
//  HelloCordova
//
//  Created by David Gonzalez Shannon on 16/12/15.
//
//

#import "MOCAPluginActionsDelegate.h"

@interface MOCAPluginActionsDelegate()

@property (nonatomic, retain)NSMutableDictionary *commands;

@end

@implementation MOCAPluginActionsDelegate


+(MOCAPluginActionsDelegate *) delegateWithDefault:(id<MOCAProximityActionsDelegate>)defaultDelegate
                                andCommandDelegate:(id<CDVCommandDelegate>)commandDelegate
{
    MOCAPluginActionsDelegate *delegate = [[MOCAPluginActionsDelegate alloc] init];
    delegate.defaultDelegate = defaultDelegate;
    delegate.commandDelegate = commandDelegate;
    return delegate;
}

-(NSDictionary*)commands {
    if (!_commands) {
        _commands = [[NSMutableDictionary alloc] init];
    }
    return _commands;
}

-(void)addCommand:(CDVInvokedUrlCommand*)command
{
    [self.commands setValue:command forKey:command.methodName];
}

-(void)sendResultForCommand:(CDVInvokedUrlCommand *)command withMessage:(id)messageContent andAction:(NSString *)action
{
    NSDictionary *message = [MOCAPluginCallbackMessage message:messageContent forAction:action];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 * Called to determine if a specific proximity action can be executed now.
 * @param service - proximity service instance
 *
 * Discussion
 *
 * It is typically implemented by the hosting app that wants to control
 * when the experiences should be displayed and when not.
 *
 * Example
 *
 * An app that displays a splash screen may want to enable proximity actions
 * to be displayed only after displaying the home screen.
 */
//-(BOOL)actionCanDisplayNow:(MOCAAction*)sender
//{
//    id command = [self.commands objectForKey:ACTION_CAN_DISPLAY_NOW];
//    if(command) {
//        MOCA_LOG_DEBUG(@"actionCanDisplayNow custom handler");
//        return YES;
//    } else {
//        return [self.defaultDelegate actionCanDisplayNow:sender];
//    }
//}

/**
 * Called when an alert notification should be displayed to a user.
 * @param alertMessage a simple string to be displayed as an alert
 */
-(BOOL)action:(MOCAAction*)sender displayNotificationAlert:(NSString *)alertMessage withSituation:(MOCAFireSituation)situation
{
    CDVInvokedUrlCommand *command = [self.commands objectForKey:DISPLAY_ALERT];
    if(command) {
        [self sendResultForCommand:command withMessage:alertMessage andAction:DISPLAY_ALERT];
        MOCA_LOG_DEBUG(@"displayNotificationAlert custom handler");
    }
    if((command && ![[command argumentAtIndex:0] boolValue]) || !command) {
        [self.defaultDelegate action:sender displayNotificationAlert:alertMessage withSituation:situation];
    }
    return YES;
}

/*
 * Called when a URL content should be displayed to a user.
 * @param url a content URL to be displayed
 */

-(BOOL)action:(MOCAAction*)sender openUrl:(NSURL*)url withSituation:(MOCAFireSituation)situation
{
    CDVInvokedUrlCommand *command = [self.commands objectForKey:OPEN_URL];
    if(command) {
        [self sendResultForCommand:command withMessage:url.absoluteString andAction:OPEN_URL];
        MOCA_LOG_DEBUG(@"openUrl custom handler");
    }
    if((command && ![[command argumentAtIndex:0] boolValue]) || !command) {
        [self.defaultDelegate action:sender openUrl:url withSituation:situation];
    }
    return YES;
}

/*
 * Called when a embedded HTML content should be displayed to a user.
 * @param html a HTML content to be displayed
 */
-(BOOL)action:(MOCAAction*)sender showHtmlWithString:(NSString*)html withSituation:(MOCAFireSituation)situation
{
    CDVInvokedUrlCommand *command = [self.commands objectForKey:SHOW_EMBEDDED_HTML];
    if(command) {
        [self sendResultForCommand:command withMessage:html andAction:SHOW_EMBEDDED_HTML];
        MOCA_LOG_DEBUG(@"showHtmlWithString custom handler");
    }
    if((command && ![[command argumentAtIndex:0] boolValue]) || !command) {
        [self.defaultDelegate action:sender showHtmlWithString:html withSituation:situation];
    }
    return YES;
    
}

/*
 * Called when a video from URL should be played to a user.
 * @param url - video content URL
 */
-(BOOL)action:(MOCAAction*)sender playVideoFromUrl:(NSURL*)url withSituation:(MOCAFireSituation)situation
{
    CDVInvokedUrlCommand *command = [self.commands objectForKey:PLAY_VIDEO_FROM_URL];
    if(command) {
        [self sendResultForCommand:command withMessage:url.absoluteString andAction:PLAY_VIDEO_FROM_URL];
        MOCA_LOG_DEBUG(@"playVideoFromUrl custom handler");
    }
    if((command && ![[command argumentAtIndex:0] boolValue]) || !command) {
        [self.defaultDelegate action:sender playVideoFromUrl:url withSituation:situation];
    }
    return YES;
}
/*
 * Called when an image from URL should be displayed to a user.
 * @param url - image URL
 */
-(BOOL)action:(MOCAAction*)sender displayImageFromUrl:(NSURL*)url withSituation:(MOCAFireSituation)situation
{
    CDVInvokedUrlCommand *command = [self.commands objectForKey:IMAGE_FROM_URL];
    if(command) {
        [self sendResultForCommand:command withMessage:url.absoluteString andAction:IMAGE_FROM_URL];
        MOCA_LOG_DEBUG(@"displayImageFromUrl custom handler");
    }
    if((command && ![[command argumentAtIndex:0] boolValue]) || !command) {
        [self.defaultDelegate action:sender displayImageFromUrl:url withSituation:situation];
    }
    return YES;
}

/*
 * Called when a Passbook pass card from URL should be displayed to a user.
 * @param url - pass URL
 */
-(BOOL)action:(MOCAAction*)sender displayPassFromUrl:(NSURL*)url withSituation:(MOCAFireSituation)situation
{
    CDVInvokedUrlCommand *command = [self.commands objectForKey:PASSBOOK_FROM_URL];
    if(command) {
        [self sendResultForCommand:command withMessage:url.absoluteString andAction:PASSBOOK_FROM_URL];
        MOCA_LOG_DEBUG(@"displayPassFromUrl custom handler");
    }
    if((command && ![[command argumentAtIndex:0] boolValue]) || !command) {
        [self.defaultDelegate action:sender displayPassFromUrl:url withSituation:situation];
    }
    return YES;
}

/*
 * Called when a user should be tagged.
 * @param tagName name of the tag
 * @param value value to be added
 */
-(BOOL)action:(MOCAAction*)sender addTag:(NSString*)tagName withValue:(NSString*)value
{
    CDVInvokedUrlCommand *command = [self.commands objectForKey:ADD_TAG];
    if(command) {
        NSDictionary *messageContent = @{ @"tagName": tagName, @"tagValue": value };
        [self sendResultForCommand:command withMessage:messageContent andAction:ADD_TAG];
        MOCA_LOG_DEBUG(@"addTag custom handler");
    }
    if((command && ![[command argumentAtIndex:0] boolValue]) || !command) {
        [self.defaultDelegate action:sender addTag:tagName withValue:value];
    }
    return YES;
}

/*
 * Called when a sound notification should be played.
 * @param soundFilename The sound file to play or `default` for the standard notification sound.
 * This file must be included in the application bundle or available in system bundle.
 */
-(BOOL)action:(MOCAAction*)sender playNotificationSound:(NSString *)soundFilename withSituation:(MOCAFireSituation)situation
{
    CDVInvokedUrlCommand *command = [self.commands objectForKey:PLAY_NOTIFICATION_SOUND];
    if(command) {
        [self sendResultForCommand:command withMessage:soundFilename andAction:PLAY_NOTIFICATION_SOUND];
        MOCA_LOG_DEBUG(@"playNotificationSound custom handler");
    }
    if((command && ![[command argumentAtIndex:0] boolValue]) || !command) {
        [self.defaultDelegate action:sender playNotificationSound:soundFilename withSituation:situation];
    }
    return YES;
}

/*
 * Called when the app should execute a custom action.
 * @param customAttribute - user provided custom attribute
 */
-(BOOL)action:(MOCAAction*)sender performCustomAction:(NSString*)customAttribute withSituation:(MOCAFireSituation)situation
{
    CDVInvokedUrlCommand *command = [self.commands objectForKey:PERFORM_CUSTOM_ACTION];
    if(command) {
        [self sendResultForCommand:command withMessage:customAttribute andAction:PERFORM_CUSTOM_ACTION];
        MOCA_LOG_DEBUG(@"performCustomAction custom handler");
    }
    if((command && ![[command argumentAtIndex:0] boolValue]) || !command) {
        [self.defaultDelegate action:sender performCustomAction:customAttribute withSituation:situation];
    }
    return YES;
}

/**
 * Called to customize the app root view that should be used to display overlay popup window.
 * @param view - default superview to add the overlay to as a child view.
 * @return selected view to be used as superview.
 */
//-(UIView*)willShowOverlayInView:(UIView*) superview
//{
//    CDVInvokedUrlCommand *command = [self.commands objectForKey:WILL_SHOW_OVERLAY_IN_VIEW];
//    if(command) {
//        MOCA_LOG_DEBUG(@"willShowOverlayInView custom handler");
//        return superview;
//    } else {
//        return [self.defaultDelegate willShowOverlayInView:superview];
//    }
//}

@end
