//
//  AppDelegate.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"

@implementation AppDelegate

@synthesize networkStatus;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Flurry startSession:@"4YTN2NG6MYJDVT9F6P7M"];
    /// ****************************************************************************
    [Parse setApplicationId:@"6glczDK1p4HX3JVuupVvX09zE1TywJRs3Xr2NYXg" clientKey:@"CdsYZN5y9Tuum2IlHhvipft0rWItCON6JoXeqYJL"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //[PFFacebookUtils initializeWithApplicationId:@"217295185096733"];
    [PFFacebookUtils initializeFacebook];
    // ****************************************************************************
    [TestFlight takeOff:@"d2f2ed31-a333-476b-b821-aa259759a131"];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    
    
    //[PF_FBSession.activeSession handleDidBecomeActive];
    
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveEventually];
    }
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}




// ****************************************************************************
// App switching methods to support Facebook Single Sign-On
// ****************************************************************************

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
