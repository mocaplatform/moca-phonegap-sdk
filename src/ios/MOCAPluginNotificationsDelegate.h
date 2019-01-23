//
//  MOCAPluginNotificationsDelegate.h
//
//  Created by Iván González on 23/01/2019.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOCAPluginNotificationsDelegate : NSObject <UNUserNotificationCenterDelegate>

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler __IOS_AVAILABLE(10.0);

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler __IOS_AVAILABLE(10.0);

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
   openSettingsForNotification:(nullable UNNotification *)notification __IOS_AVAILABLE(12.0);

- (void)setOriginalDelegate:(id<UNUserNotificationCenterDelegate>) delegate;

@end

NS_ASSUME_NONNULL_END
