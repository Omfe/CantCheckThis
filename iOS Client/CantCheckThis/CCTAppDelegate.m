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



@implementation CCTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController;
    CCTSignInViewController *signinViewController;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary* mainBundleSettings = [defaults persistentDomainForName:bundleId];
    if (mainBundleSettings) {
        NSData *loggedInUser = [defaults objectForKey:@"loggedInUser"];
        [CCTAuthenticationManager sharedManager].loggedInUser = [NSKeyedUnarchiver unarchiveObjectWithData:loggedInUser];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    signinViewController = [[CCTSignInViewController alloc] initWithNibName:@"CCTSignInViewController" bundle:nil];
    navigationController = [[UINavigationController alloc] initWithRootViewController:signinViewController];
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
