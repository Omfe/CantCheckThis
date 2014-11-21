//
//  CCTAppDelegate.m
//  CantCheckThis
//
//  Created by Omar Gudino on 8/26/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTAppDelegate.h"
#import "CCTSignInViewController.h"
#import "CCTAuthenticationManager.h"
#import "CCTCheckInViewController.h"
#import <FYX/FYX.h>
#import <FYX/FYXAppInfo.h>
#import <ContextCore/QLContextCoreConnector.h>
#import <ContextCore/QLPushNotificationsConnector.h>
#import <FYX/FYXVisitManager.h>
#import <FYX/FYXTransmitter.h>
#import <FYX/FYXSightingManager.h>

@interface CCTAppDelegate () <FYXServiceDelegate, FYXVisitDelegate>

@property (nonatomic) FYXVisitManager *visitManager;

@end

@implementation CCTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FYX disableLocationUpdates];
    //beacon
    [FYX setAppId:@"f093e44c3472eb08cd455de5defe6d770d096c5b24031a4765da9a8fbe35fc0d"
        appSecret:@"fd087b2a23da20ee98699edb261ae99943d2e332706581fcb126d7606f99fd5d"
      callbackUrl:@"omfecantcheckthis://authcode"];
    [FYX startService:self];
    
    QLContextCoreConnector *connector = [QLContextCoreConnector new];
    [connector enableFromViewController:self.window.rootViewController success:^
     {
         NSLog(@"Gimbal enabled");
     } failure:^(NSError *error) {
         NSLog(@"Failed to initialize gimbal %@", error);
     }];
    
    [QLPushNotificationsConnector didFinishLaunchingWithOptions:launchOptions];
    [QLPushNotificationsConnector registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary* mainBundleSettings = [defaults persistentDomainForName:bundleId];
    if (mainBundleSettings) {
        NSData *loggedInUser = [defaults objectForKey:@"loggedInUser"];
        [CCTAuthenticationManager sharedManager].loggedInUser = [NSKeyedUnarchiver unarchiveObjectWithData:loggedInUser];
    }
    
    UINavigationController *navigationController;
    CCTSignInViewController *signinViewController;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    signinViewController = [[CCTSignInViewController alloc] initWithNibName:@"CCTSignInViewController" bundle:nil];
    navigationController = [[UINavigationController alloc] initWithRootViewController:signinViewController];
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0/255.0f green:153/255.0f blue:255/255.0f alpha:1.0f];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0/255.0f green:153/255.0f blue:255/255.0f alpha:1.0f]];
    self.window.tintColor = [UIColor whiteColor];
    [[UITextField appearance] setTintColor:[UIColor grayColor]];

    return YES;
}

//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//    
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application
//{
//    [FYX disableLocationUpdates];
//    //beacon
//    [FYX setAppId:@"f093e44c3472eb08cd455de5defe6d770d096c5b24031a4765da9a8fbe35fc0d"
//        appSecret:@"fd087b2a23da20ee98699edb261ae99943d2e332706581fcb126d7606f99fd5d"
//      callbackUrl:@"omfecantcheckthis://authcode"];
//    [FYX startService:self];
//    
//    QLContextCoreConnector *connector = [QLContextCoreConnector new];
//    [connector enableFromViewController:self.window.rootViewController success:^
//     {
//         NSLog(@"Gimbal enabled");
//     } failure:^(NSError *error) {
//         NSLog(@"Failed to initialize gimbal %@", error);
//     }];
//    
//    [QLPushNotificationsConnector registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    
//}

- (void)didArrive:(FYXVisit *)visit;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary* mainBundleSettings = [defaults persistentDomainForName:bundleId];
    if (![CCTAuthenticationManager sharedManager].loggedInUser) {
        return;
    }
    if (mainBundleSettings) {
        [self.visitManager stop];
        NSData *loggedInUser = [defaults objectForKey:@"loggedInUser"];
        [CCTAuthenticationManager sharedManager].loggedInUser = [NSKeyedUnarchiver unarchiveObjectWithData:loggedInUser];
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state != UIApplicationStateActive) {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:10];
            localNotification.alertBody = [NSString stringWithFormat:@"You've arrived at the %@",visit.transmitter.name];
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            CCTCheckInViewController *checkInViewController;
            checkInViewController = [[CCTCheckInViewController alloc] init];
            [checkInViewController checkIn];
        } else {
            CCTCheckInViewController *checkInViewController;
            checkInViewController = [[CCTCheckInViewController alloc] init];
            [checkInViewController checkIn];
        }
        NSLog(@"I arrived at a Gimbal Beacon!!! %@", visit.transmitter.name);
    }
}

- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary* mainBundleSettings = [defaults persistentDomainForName:bundleId];
    if (![CCTAuthenticationManager sharedManager].loggedInUser) {
        return;
    }
    if (mainBundleSettings) {
        [self.visitManager stop];
        NSData *loggedInUser = [defaults objectForKey:@"loggedInUser"];
        [CCTAuthenticationManager sharedManager].loggedInUser = [NSKeyedUnarchiver unarchiveObjectWithData:loggedInUser];
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state != UIApplicationStateActive) {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:10];
            localNotification.alertBody = [NSString stringWithFormat:@"You've been sighted at the %@",visit.transmitter.name];
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            CCTCheckInViewController *checkInViewController;
            checkInViewController = [[CCTCheckInViewController alloc] init];
            [checkInViewController checkIn];
        } else {
            CCTCheckInViewController *checkInViewController;
            checkInViewController = [[CCTCheckInViewController alloc] init];
            [checkInViewController checkIn];
        }
        NSLog(@"I arrived at a Gimbal Beacon!!! %@", visit.transmitter.name);
    }
}

- (void)didDepart:(FYXVisit *)visit
{
    [FYX startService:self];
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state != UIApplicationStateActive) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:10];
        localNotification.alertBody = [NSString stringWithFormat:@"You've departed the %@",visit.transmitter.name];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

- (void)serviceStarted
{
    // this will be invoked if the service has successfully started
    // bluetooth scanning will be started at this point.
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:[NSString stringWithString:FYXHighAccuracyLocation] forKey:FYXLocationModeKey];
    [FYX enableLocationUpdatesWithOptions:options];

    self.visitManager = [[FYXVisitManager alloc] init];
    self.visitManager.delegate = self;
    [options setObject:[NSNumber numberWithInt:240] forKey:FYXVisitOptionDepartureIntervalInSecondsKey];
    [options setObject:[NSNumber numberWithInt:FYXSightingOptionSignalStrengthWindowNone] forKey:FYXSightingOptionSignalStrengthWindowKey];
    [options setObject:[NSNumber numberWithInt:-75] forKey:FYXVisitOptionArrivalRSSIKey];
    [options setObject:[NSNumber numberWithInt:-80] forKey:FYXVisitOptionDepartureRSSIKey];
    [self.visitManager startWithOptions:options];
    
    NSLog(@"FYX Service Successfully Started");
}

- (void)startServiceFailed:(NSError *)error
{
    // this will be called if the service has failed to start
    NSLog(@"%@", error);
}

//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//{
//    [QLPushNotificationsConnector didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
//}
//
//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    [QLPushNotificationsConnector didReceiveRemoteNotification:userInfo];
//}

@end
