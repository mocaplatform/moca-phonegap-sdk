//
//  MOCAPluginNotificationsDelegate.m
//  NineTeenVer
//
//  Created by Iván González on 23/01/2019.
//

#import "MOCAPluginNotificationsDelegate.h"
#import "MOCA.h"

@implementation MOCAPluginNotificationsDelegate {
    id<UNUserNotificationCenterDelegate> originalDelegate;
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    //handle callback and do not cascade it if it is a MOCA Notification
    if (MOCA.initialized && [MOCA isMocaNotification:notification]) {
        [MOCA userNotificationCenter:center
             willPresentNotification:notification
               withCompletionHandler:completionHandler];
        return;
    }
    //otherwise, forward the callback to the original delegate (if any)
    if(originalDelegate && [originalDelegate respondsToSelector:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:)]) {
        [originalDelegate userNotificationCenter:center willPresentNotification: notification withCompletionHandler:completionHandler];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    
    if (MOCA.initialized && [MOCA isMocaNotification:response]) {
        [MOCA userNotificationCenter:center
      didReceiveNotificationResponse:response
               withCompletionHandler:completionHandler];
        return;
    }
    if(originalDelegate && [originalDelegate respondsToSelector:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
        [originalDelegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
   openSettingsForNotification:(nullable UNNotification *)notification {
    //MOCA does not implement this callback (yet), so just forward it to the original delegate if any
    if(originalDelegate) {
        if(@available(iOS 12.0, *)){ //Note: do not refactor to if(originalDelegate && @available). This will deactivate the @available guard
            [originalDelegate userNotificationCenter:center openSettingsForNotification:notification];
        }
    }
}

- (void)setOriginalDelegate:(id<UNUserNotificationCenterDelegate>) delegate{
    if(!delegate) {
        return;
    }
    self.originalDelegate = delegate;
}

@end
