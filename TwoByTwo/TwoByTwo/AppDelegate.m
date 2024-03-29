//
//  AppDelegate.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "AppDelegate.h"
#import "Crittercism.h"
#import "TestFlight.h"
#import "FeedViewController.h"
#import "UIWindow+Animation.h"
#import "PDPViewController.h"
#import "MainViewController.h"


#define MIXPANEL_TOKEN @"47b0765ad75655a0170dc3a1742abc47"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    // Crittercism
    [Crittercism enableWithAppID:@"52a0a4f04002054d18000001"];

    // TestFlight
    [TestFlight takeOff:@"f14b6606-f5bd-460a-be98-4da27a654296"];
    
    // MixPanel
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    // Enable Crash Reporting
    [ParseCrashReporting enable];
    
    //[Parse enableLocalDatastore];
    
    // Parse
    [Parse setApplicationId:@"6glczDK1p4HX3JVuupVvX09zE1TywJRs3Xr2NYXg" clientKey:@"CdsYZN5y9Tuum2IlHhvipft0rWItCON6JoXeqYJL"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"usi9Q97qeqiUUso9Do7BMSuhO" consumerSecret:@"qKR6zE5ggJbVOq9yzV1ScZuRTXGFKTtNfM1XrGHdMyL61lgcMu"];
    
    

    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveEventually];
    }
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    
    // Root View
    [self setAppearance];
    
    

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    if ([PFUser currentUser]) {
        [self showMainViewController];
    }
    else {
        [self showLoginViewController];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];

    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        UINavigationController *navController = (id)self.window.rootViewController;
        [(MainViewController *)navController.topViewController showNotificationsAnimated:NO];
        //TODO: push in notification detail page?
    }
    
    return YES;
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    [FBSession.activeSession handleDidBecomeActive];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveEventually];
    }
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Absolute :%@, Base :%@, Fragment: %@, Parameter: %@, Query: %@, Scheme: %@", [url absoluteString], [url baseURL], [url fragment], [url parameterString], [url query], [url scheme]);
    //Absolute :twobytwo://deeplink?pdp=123, Base :(null), Fragment: (null), Parameter: (null), Query: pdp=123, Scheme: twobytwo
    
    if([url query]){
        NSArray* arr = [[url query] componentsSeparatedByString:@"="];
        
        self.pdpID = [arr objectAtIndex:1];
        
        NSLog(@"pdp %@",self.pdpID);
    }
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}


#pragma mark - Push Notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [PFPush storeDeviceToken:newDeviceToken];
    
    // Subscribe to the global broadcast channel.
    [PFPush subscribeToChannelInBackground:@""];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    [[PFInstallation currentInstallation] addUniqueObject:@"" forKey:@"channel"];
    if ([PFUser currentUser]) {
        // Make sure they are subscribed to their private push channel
        NSString *privateChannelName = [[PFUser currentUser] objectId];
        if (privateChannelName && privateChannelName.length > 0) {
            NSLog(@"Subscribing user to %@", privateChannelName);
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
        }
    }
    [[PFInstallation currentInstallation] saveEventually];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}


#pragma mark - Root View Controller

- (void)showLoginViewController
{
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateInitialViewController];
    [self.window setRootViewController:controller animated:YES];
}

- (void)showMainViewController
{
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"MainV2" bundle:nil] instantiateInitialViewController];
    [self.window setRootViewController:controller animated:YES];
}


#pragma mark - Convenience Methods

+ (AppDelegate *)delegate
{
    return (id)[UIApplication sharedApplication].delegate;
}

- (void)setAppearance
{
    [[UILabel appearanceWhenContainedIn:[UITableViewCell class], nil] setTextColor:[UIColor appGrayColor]];
    [[UILabel appearanceWhenContainedIn:[UITableViewCell class], nil] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];

    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor appGrayColor]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:13]];

    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor whiteColor]];

    [[UINavigationBar appearance] setTintColor:[UIColor appGrayColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor appGrayColor],
                                                           NSFontAttributeName:[UIFont appMediumFontOfSize:14],
                                                           }];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    UIImage *barBackBtnImg = [[UIImage imageNamed:@"backArrow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24.0, 0, 0)];
    [[UINavigationBar appearance] setBackIndicatorImage:barBackBtnImg];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:barBackBtnImg];
}

@end
