//
//  MOCAAutoIntegration.m
//  HelloCordova
//
//  Created by Iván González on 12/10/16.
//
//

#import "MOCAAutoIntegration.h"
#import "MOCALog.h"
#import "MOCA.h"
#import "objc/runtime.h"

static MOCAAutoIntegration *_instance;

@implementation MOCAAutoIntegration {
    NSMutableDictionary *_originalMethods;
}


+ (void) autoIntegrate
{
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        _instance = [[MOCAAutoIntegration alloc] init];
        [_instance swizzleAppDelegate];
    });
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _originalMethods = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void) swizzleAppDelegate
{
    id delegate = [UIApplication sharedApplication].delegate;
    if (!delegate) {
        MOCA_LOG_ERROR(@"Cannot retrieve AppDelegate. Automatic integration failed");
        return;
    }
    
    Class class = [delegate class];
    
    // Push notifications token
    [self swizzle:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)
   implementation:(IMP)ApplicationDidRegisterForRemoteNotificationsWithDeviceToken class:class];
    
    //TODO token errors
    
    // Silent notifications
    [self swizzle:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)
   implementation:(IMP)ApplicationDidReceiveRemoteNotificationFetchCompletionHandler
            class:class];
    
    // Local push notifications
    [self swizzle:@selector(application:didReceiveLocalNotification:)
   implementation:(IMP)ApplicationDidReceiveLocalNotification class:class];
    
    
}

- (void)swizzle:(SEL)selector implementation:(IMP)implementation class:(Class)class {
    Method method = class_getInstanceMethod(class, selector);
    if (method) {
        MOCA_LOG_DEBUG(@"Swizzling implementation for %@ class %@", NSStringFromSelector(selector), class);
        IMP existing = method_setImplementation(method, implementation);
        if (implementation != existing) {
            [self storeOriginalImplementation:existing selector:selector class:class];
        }
    } else {
        struct objc_method_description description = protocol_getMethodDescription(@protocol(UIApplicationDelegate), selector, NO, YES);
        MOCA_LOG_DEBUG(@"Adding implementation for %@ class %@", NSStringFromSelector(selector), class);
        class_addMethod(class, selector, implementation, description.types);
    }
}

void ApplicationDidRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, UIApplication *application, NSData *deviceToken) {
    
    [MOCA registerDeviceToken:deviceToken];
    
    //Execute original method, if any
    IMP original = [_instance originalImplementation:_cmd class:[self class]];
    if (original) {
        ((void(*)(id, SEL, UIApplication *, NSData *))original)(self, _cmd, application, deviceToken);
    }
}

void ApplicationDidReceiveRemoteNotificationFetchCompletionHandler(id self,
                                                                   SEL _cmd,
                                                                   UIApplication *application,
                                                                   NSDictionary *userInfo,
                                                                   void (^handler)(UIBackgroundFetchResult)) {
    if (MOCA.initialized)
    {
        [MOCA handleRemoteNotification:userInfo fetchCompletionHandler:handler];
    }
    
    //call original implementation
    
    IMP original = [_instance originalImplementation:_cmd class:[self class]];
    ((void(*)(id, SEL, UIApplication *, NSDictionary *,
              void (^)(UIBackgroundFetchResult)))original)(self, _cmd, application, userInfo, handler);
    

}

void ApplicationDidReceiveLocalNotification(id self, SEL _cmd, UIApplication *application ,UILocalNotification *notification) {
    if (MOCA.initialized)
    {
        [MOCA handleLocalNotification:notification];
    }
    
    //call original implementation
    IMP original = [_instance originalImplementation:_cmd class:[self class]];
    if(original) {
        ((void(*)(id, SEL, UIApplication *, UILocalNotification *))original)(self, _cmd, application, notification);
    }
}


- (IMP)originalImplementation:(SEL)selector class:(Class)class {
    NSString *selectorString = NSStringFromSelector(selector);
    NSString *classString = NSStringFromClass(class);
    
    if (!_originalMethods[classString]) {
        return nil;
    }
    
    NSValue *value = _originalMethods[classString][selectorString];
    if (!value) {
        return nil;
    }
    
    IMP implementation;
    [value getValue:&implementation];
    return implementation;
}

- (void)storeOriginalImplementation:(IMP)implementation selector:(SEL)selector class:(Class)class {
    NSString *selectorString = NSStringFromSelector(selector);
    NSString *classString = NSStringFromClass(class);
    
    if (!_originalMethods[classString]) {
        _originalMethods[classString] = [NSMutableDictionary dictionary];
    }
    
    _originalMethods[classString][selectorString] = [NSValue valueWithPointer:implementation];
}

@end
