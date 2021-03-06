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
#import "CCTUsersViewController.h"
#import "CCTUserProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CCTSignInViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic) NSArray *fieldArray;

@end

@implementation CCTSignInViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier]
    } else {
        // iOS 7.0 or later
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0/255.0f green:153/255.0f blue:255/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    }
    
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
//    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                           [UIFont fontWithName:@"Helvetica-Bold" size:17.0], NSFontAttributeName, nil]];
    
    [super viewDidLoad];
    self.title = @"CAN'T CHECK THIS";
    self.passwordTextField.secureTextEntry = YES;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.fieldArray = [NSArray arrayWithObjects: self.emailTextField, self.passwordTextField, nil];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hideTextView:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.emailTextField.layer.borderColor = [[UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0] CGColor];
    self.emailTextField.layer.borderWidth=1.0;
    self.passwordTextField.layer.borderColor = [[UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0] CGColor];
    self.passwordTextField.layer.borderWidth=1.0;
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    NSUInteger index = [self.fieldArray indexOfObject:textField];
    if (index == NSNotFound || index + 1 == self.fieldArray.count){
        if ([self isValidInput]) {
            [self login];
        }
        return NO;
    }
    
    id nextField = [self.fieldArray objectAtIndex:index + 1];
    textField = nextField;
    [nextField becomeFirstResponder];
    
    return NO;
}

- (void)_hideTextView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        CCTWebServicesManager *webServicesManager;
        NSString *email = [alertView textFieldAtIndex:0].text;
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        BOOL myStringMatchesRegEx=[emailTest evaluateWithObject:email];
        
        if (myStringMatchesRegEx) {
            webServicesManager = [[CCTWebServicesManager alloc] init];
            [webServicesManager forgotPasswordWithEmail:email andCompletion:^(NSString *message, NSError *error) {
                UIAlertView *confirmation=[[UIAlertView alloc] initWithTitle:@"Email Request"  message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [confirmation show];
            }];
        } else {
            UIAlertView *emailSyntaxError=[[UIAlertView alloc] initWithTitle:@"Email Request"  message:@"Not a email syntax" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [emailSyntaxError show];
        }
    }
}

#pragma mark - Action Methods
- (IBAction)loginButtonWasPressed:(id)sender
{
    if ([self isValidInput]) {
        [self login];
    }
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
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    [indicator setCenter:self.view.center];
    [[CCTAuthenticationManager sharedManager] loginWithEmail:self.emailTextField.text withPassword:self.passwordTextField.text andCompletion:^(NSString *message, NSError *error) {
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Login!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            return;
        }
        [self.view endEditing:YES];
        self.passwordTextField.text = @"";
        
        [indicator removeFromSuperview];
        [self loggedInUserTravelsToCheckInView];
    }];
}

- (void)navigateToUserProfile:(UIBarButtonItem *)sender
{
    CCTUserProfileViewController *userProfileViewController;
    UINavigationController *navigationController;
    
    userProfileViewController = [[CCTUserProfileViewController alloc] initWithNibName:@"CCTUserProfileViewController" bundle:nil];
    navigationController = [[UINavigationController alloc] initWithRootViewController:userProfileViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)loggedInUserTravelsToCheckInView
{
    UITabBarController *tabBarController;
    
    tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:[self tabBarViewControllers]];
    tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"User" style:UIBarButtonItemStyleBordered target:self action:@selector(navigateToUserProfile:)];
    tabBarController.navigationItem.hidesBackButton = YES;
    tabBarController.title = [CCTAuthenticationManager sharedManager].loggedInUser.firstName;
    
    [self.navigationController pushViewController:tabBarController animated:YES];
}

- (NSArray *)tabBarViewControllers
{
   // CCTCheckInViewController *checkInViewController;
    CCTDatePickerViewController *datePickerViewController;
    CCTUsersViewController *usersViewController;
   // UINavigationController *checkInNavController;
    UINavigationController *datePickerNavController;
    UINavigationController *usersNavController;
    NSArray *viewControllers;
    
   // checkInViewController = [[CCTCheckInViewController alloc] initWithNibName:@"CCTCheckInViewController" bundle:nil];
    datePickerViewController = [[CCTDatePickerViewController alloc] initWithNibName:@"CCTDatePickerViewController" bundle:nil];
    usersViewController = [[CCTUsersViewController alloc] initWithNibName:@"CCTUsersViewController" bundle:nil];
    
    //checkInNavController = [[UINavigationController alloc] initWithRootViewController:checkInViewController];
    datePickerNavController = [[UINavigationController alloc] initWithRootViewController:datePickerViewController];
    usersNavController = [[UINavigationController alloc] initWithRootViewController:usersViewController];
    
    viewControllers = @[datePickerNavController, usersNavController];
    
    UIImage *datePickerImage = [UIImage imageNamed:@"ClockTabBar.png"];
    UIImage *usersImage = [UIImage imageNamed:@"UsersTabBar.png"];
    
    [datePickerViewController setTitle:@"Daily Check Ins"];
    [datePickerViewController tabBarItem].image = datePickerImage;
    [usersViewController setTitle:@"Users"];
    [usersViewController tabBarItem].image = usersImage;
    
    return viewControllers;
}

- (BOOL)isValidInput
{
    NSString *email = self.emailTextField.text;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL myStringMatchesRegEx=[emailTest evaluateWithObject:email];
    
    if (self.emailTextField.text.length == 0 || self.passwordTextField.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Login!" message:@"Fill the text fields" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return NO;
    } else if (!myStringMatchesRegEx){
        [[[UIAlertView alloc] initWithTitle:@"Login!" message:@"Enter a valid email id" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return NO;
    } else{
        return YES;
    }
}
@end
