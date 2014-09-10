//
//  CCTCheckInViewController.m
//  CantCheckThis
//
//  Created by Omar Gudino on 8/28/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTCheckInViewController.h"
#import "CCTWebServicesManager.h"
#import "CCTAuthenticationManager.h"
#import "CCTResetPasswordViewController.h"

@interface CCTCheckInViewController ()
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;

@end

@implementation CCTCheckInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Action Methods
- (IBAction)checkInButtonWasPressed:(id)sender
{
    [self checkIn];
}

- (IBAction)resetPasswordButtonWasPressed:(id)sender
{
    CCTResetPasswordViewController *resetPasswordViewController;
    UINavigationController *navigationController;
    
    resetPasswordViewController = [[CCTResetPasswordViewController alloc] initWithNibName:@"CCTResetPasswordViewController" bundle:nil];
    navigationController = [[UINavigationController alloc] initWithRootViewController:resetPasswordViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)checkIn
{
    CCTWebServicesManager *webServicesManager;
    webServicesManager = [[CCTWebServicesManager alloc] init];
    
    [webServicesManager checkInWithCompletion:^(NSString *message, NSError *error)
     {
         if (error) {
             [[[UIAlertView alloc] initWithTitle:@"You already checked in!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
             return;
         }
         
         [[[UIAlertView alloc] initWithTitle:@"Thank you for Checking In!" message:[NSString stringWithFormat:@"%@", message] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
         [self.view endEditing:YES];
     }];
}
@end
