//
//  CCTAppDelegate.m
//  CantCheckThis
//
//  Created by Omar Gudino on 8/26/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTAppDelegate.h"
#import "CCTSignInViewController.h"

@implementation CCTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController;
    CCTSignInViewController *signinViewController;
    
    //    NSDictionary *item = @{ @"num": @1};
    //    MSTable *itemTable = [client tableWithName:@"Item"];
    //
    //    [itemTable insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
    //        if (error) {
    //            NSLog(@"Error: %@", error);
    //        } else {
    //            NSLog(@"Item inserted, id: %@", [insertedItem objectForKey:@"id"]);
    //        }
    //    }];
    
    
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
