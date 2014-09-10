//
//  CCTSignInViewController.m
//  CantCheckThis
//
//  Created by Omar Gudino on 8/26/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTSignInViewController.h"
#import "CCTAuthenticationManager.h"
#import "CCTCheckInViewController.h"
#import "CCTDatePickerViewController.h"
#import "CCTWebServicesManager.h"
#import "CCTUser.h"
#import "CCTRegisterViewController.h"

@interface CCTSignInViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation CCTSignInViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (self.emailTextField.text.length == 0) {
        [self.emailTextField becomeFirstResponder];
    } else {
        [self.passwordTextField becomeFirstResponder];
    }
    
    if ([CCTAuthenticationManager sharedManager].loggedInUser)
    {
        [self loggedInUserTravelsToCheckInView];
    }
}

- (void)viewDidLoad
{
    UITapGestureRecognizer *tapGestureRecognizer;
    
    [super viewDidLoad];
    self.title = @"Login";
    self.passwordTextField.secureTextEntry = YES;
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hideTextView:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField == self.emailTextField ) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self login];
    }
    
    return YES;
}

- (void)_hideTextView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *email = [alertView textFieldAtIndex:0].text;
        CCTWebServicesManager *webServicesManager;
        
        webServicesManager = [[CCTWebServicesManager alloc] init];
        [webServicesManager forgotPasswordWithEmail:email andCompletion:^(NSString *message, NSError *error) {
            UIAlertView *confirmation=[[UIAlertView alloc] initWithTitle:@"Thank You!"      message:@"Email Sent" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [confirmation show];
        }];
    }
}

#pragma mark - Action Methods
- (IBAction)loginButtonWasPressed:(id)sender
{
    [self login];
}

- (IBAction)registerButtonWasPressed:(id)sender
{
    CCTRegisterViewController *registerViewController;
    UINavigationController *navigationController;
    
    registerViewController = [[CCTRegisterViewController alloc] initWithNibName:@"CCTRegisterViewController" bundle:nil];
    navigationController = [[UINavigationController alloc] initWithRootViewController:registerViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)forgotPasswordButtonWasPressed:(id)sender
{
    UIAlertView *forgotPassword=[[UIAlertView alloc] initWithTitle:@"Forgot Password"      message:@"Please enter your email id" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    forgotPassword.alertViewStyle=UIAlertViewStylePlainTextInput;
    [forgotPassword textFieldAtIndex:0].delegate=self;
    [forgotPassword show];
}

#pragma mark - Private Methods
- (void)login
{
    [[CCTAuthenticationManager sharedManager] loginWithEmail:self.emailTextField.text withPassword:self.passwordTextField.text andCompletion:^(NSString *message, NSError *error) {
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"There was an error!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            return;
        }
        [self.view endEditing:YES];
        self.passwordTextField.text = @"";
        
        [self loggedInUserTravelsToCheckInView];
    }];
}

- (void)logout:(UIBarButtonItem *)sender
{
    [[CCTAuthenticationManager sharedManager] logoutWithCompletion:^(NSString *message, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"There was an error!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            return;
        }
        
        [[[UIAlertView alloc] initWithTitle:@"Logged Out!" message:[NSString stringWithFormat:@"%@", message] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (void)loggedInUserTravelsToCheckInView
{
    UITabBarController *tabBarController;
    
    tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:[self tabBarViewControllers]];
    tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
    tabBarController.navigationItem.hidesBackButton = YES;
    tabBarController.title = [CCTAuthenticationManager sharedManager].loggedInUser.firstName;
    
    [self.navigationController pushViewController:tabBarController animated:YES];
}

- (NSArray *)tabBarViewControllers
{
    CCTCheckInViewController *checkInViewController;
    CCTDatePickerViewController *datePickerViewController;
    UINavigationController *checkInNavController;
    UINavigationController *datePickerNavController;
    NSArray *viewControllers;
    
    checkInViewController = [[CCTCheckInViewController alloc] initWithNibName:@"CCTCheckInViewController" bundle:nil];
    datePickerViewController = [[CCTDatePickerViewController alloc] initWithNibName:@"CCTDatePickerViewController" bundle:nil];
    
    checkInNavController = [[UINavigationController alloc] initWithRootViewController:checkInViewController];
    datePickerNavController = [[UINavigationController alloc]initWithRootViewController:datePickerViewController];
    
    viewControllers = @[checkInNavController, datePickerNavController];
    
    [datePickerViewController setTitle:@"Daily Check Ins"];
    [checkInViewController setTitle:@"Check In!"];
    return viewControllers;
}
@end
