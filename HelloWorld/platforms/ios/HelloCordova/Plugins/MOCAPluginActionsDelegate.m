//
//  MOCAPluginActionsDelegate.m
//  HelloCordova
//
//  Created by David Gonzalez Shannon on 16/12/15.
//
//

#import "MOCAPluginActionsDelegate.h"

@interface MOCAPluginActionsDelegate()

@property (nonatomic, retain)NSDictionary *commands;

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

-(void)addCommand:(CDVInvokedUrlCommand*)command
{
    
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
-(BOOL)actionCanDisplayNow:(MOCAAction*)sender
{
    id command = [self.commands objectForKey:@"actionCanDisplayNow"];
    if(command) {
        MOCA_LOG_DEBUG(@"actionCanDisplayNow custom handler");
        return YES;
    } else {
        return [self.defaultDelegate actionCanDisplayNow:sender];
    }
}

/**
 * Called when an alert notification should be displayed to a user.
 * @param alertMessage a simple string to be displayed as an alert
 */
-(void)action:(MOCAAction*)sender displayNotificationAlert:(NSString *)alertMessage
{
    id command = [self.commands objectForKey:@"displayNotificationAlert"];
    if(command) {
        MOCA_LOG_DEBUG(@"displayNotificationAlert custom handler");
    } else {
        [self.defaultDelegate action:sender displayNotificationAlert:alertMessage];
    }
}

/*
 * Called when a URL content should be displayed to a user.
 * @param url a content URL to be displayed
 */

-(void)action:(MOCAAction*)sender openUrl:(NSURL*)url
{
    id command = [self.commands objectForKey:@"openUrl"];
    if(command) {
        MOCA_LOG_DEBUG(@"openUrl custom handler");
    } else {
        [self.defaultDelegate action:sender openUrl:url];
    }
}

/*
 * Called when a embedded HTML content should be displayed to a user.
 * @param html a HTML content to be displayed
 */
-(void)action:(MOCAAction*)sender showHtmlWithString:(NSString*)html
{
    id command = [self.commands objectForKey:@"showHtmlWithString"];
    if(command) {
        MOCA_LOG_DEBUG(@"showHtmlWithString custom handler");
    } else {
        [self.defaultDelegate action:sender showHtmlWithString:html];
    }
}

/*
 * Called when a video from URL should be played to a user.
 * @param url - video content URL
 */
-(void)action:(MOCAAction*)sender playVideoFromUrl:(NSURL*)url
{
    id command = [self.commands objectForKey:@"playVideoFromUrl"];
    if(command) {
        MOCA_LOG_DEBUG(@"playVideoFromUrl custom handler");
    } else {
        [self.defaultDelegate action:sender playVideoFromUrl:url];
    }
}
/*
 * Called when an image from URL should be displayed to a user.
 * @param url - image URL
 */
-(void)action:(MOCAAction*)sender displayImageFromUrl:(NSURL*)url
{
    id command = [self.commands objectForKey:@"displayImageFromUrl"];
    if(command) {
        MOCA_LOG_DEBUG(@"displayImageFromUrl custom handler");
    } else {
        [self.defaultDelegate action:sender displayImageFromUrl:url];
    }
}

/*
 * Called when a Passbook pass card from URL should be displayed to a user.
 * @param url - pass URL
 */
-(void)action:(MOCAAction*)sender displayPassFromUrl:(NSURL*)url
{
    id command = [self.commands objectForKey:@"displayPassFromUrl"];
    if(command) {
        MOCA_LOG_DEBUG(@"displayPassFromUrl custom handler");
    } else {
        [self.defaultDelegate action:sender displayPassFromUrl:url];
    }
}

/*
 * Called when a user should be tagged.
 * @param tagName name of the tag
 * @param value value to be added
 */
-(void)action:(MOCAAction*)sender addTag:(NSString*)tagName withValue:(NSString*)value
{
    id command = [self.commands objectForKey:@"addTag"];
    if(command) {
        MOCA_LOG_DEBUG(@"addTag custom handler");
    } else {
        [self.defaultDelegate action:sender addTag:tagName withValue:value];
    }
}

/*
 * Called when a sound notification should be played.
 * @param soundFilename The sound file to play or `default` for the standard notification sound.
 * This file must be included in the application bundle or available in system bundle.
 */
-(void)action:(MOCAAction*)sender playNotificationSound:(NSString *)soundFilename
{
    id command = [self.commands objectForKey:@"playNotificationSound"];
    if(command) {
        MOCA_LOG_DEBUG(@"playNotificationSound custom handler");
    } else {
        [self.defaultDelegate action:sender playNotificationSound:soundFilename];
    }
}

/*
 * Called when the app should execute a custom action.
 * @param customAttribute - user provided custom attribute
 */
-(void)action:(MOCAAction*)sender performCustomAction:(NSString*)customAttribute
{
    id command = [self.commands objectForKey:@"performCustomAction"];
    if(command) {
        MOCA_LOG_DEBUG(@"performCustomAction custom handler");
    } else {
        [self.defaultDelegate action:sender performCustomAction:customAttribute];
    }
}

/**
 * Called to customize the app root view that should be used to display overlay popup window.
 * @param view - default superview to add the overlay to as a child view.
 * @return selected view to be used as superview.
 */
-(UIView*)willShowOverlayInView:(UIView*) superview
{
    id command = [self.commands objectForKey:@"willShowOverlayInView"];
    if(command) {
        MOCA_LOG_DEBUG(@"willShowOverlayInView custom handler");
        return superview;
    } else {
        return [self.defaultDelegate willShowOverlayInView:superview];
    }
}

@end
