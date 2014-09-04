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

#pragma mark - Action Methods
- (IBAction)loginButtonWasPressed:(id)sender
{
    [self login];
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
        
        UITabBarController *tabBarController;
        
        tabBarController = [[UITabBarController alloc] init];
        [tabBarController setViewControllers:[self tabBarViewControllers]];
        tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
        tabBarController.navigationItem.hidesBackButton = YES;

        
        [self.navigationController pushViewController:tabBarController animated:YES];
    }];
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
    
    return viewControllers;
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

@end

//    self.navigationItem.hidesBackButton = YES;
