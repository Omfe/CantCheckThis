//
//  CCTRegisterViewController.m
//  CantCheckThis
//
//  Created by Omar Gudino on 9/4/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTRegisterViewController.h"
#import "CCTAuthenticationManager.h"
#import "CCTCheckInViewController.h"
#import "CCTDatePickerViewController.h"
#import "CCTWebServicesManager.h"
#import "CCTSignInViewController.h"
#import "CCTSchedule.h"

@interface CCTRegisterViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *schedulePickerView;
@property (strong, nonatomic) NSArray *schedules;

@end
//Si hiciste Register te loggea pero cuando haces logout te manda a la pagina de register
@implementation CCTRegisterViewController

- (void)viewDidLoad
{
    UITapGestureRecognizer *tapGestureRecognizer;
    
    [scroller setScrollEnabled:YES];
    [self fetchAllSchedules];
    [super viewDidLoad];
    [self setTitle:@"Register"];
    UIBarButtonItem *dismissViewBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController:)];
    UIBarButtonItem *confirmRegistrationBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(confirmRegistration:)];
    self.navigationItem.leftBarButtonItem = dismissViewBarButtonItem;
    self.navigationItem.rightBarButtonItem = confirmRegistrationBarButtonItem;
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hideTextView:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.passwordTextField.secureTextEntry = YES;
    self.confirmPasswordTextField.secureTextEntry = YES;
    
}

- (void)viewDidLayoutSubviews
{
    [scroller setContentSize:CGSizeMake(320, 700)];
}

#pragma mark - UITextFieldDelegate Methods
- (void)_hideTextView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
}


- (void)dismissViewController:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirmRegistration:(UIBarButtonItem *) sender
{
    if ([self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        NSString *scheduleId;
        CCTSchedule *selectedSchedule;
        
        selectedSchedule = [[CCTSchedule alloc] init];
        selectedSchedule = [self.schedules  objectAtIndex:[self. schedulePickerView selectedRowInComponent:0]];
        scheduleId = [NSString stringWithFormat:@"%@", selectedSchedule.scheduleId];
        
        [[CCTAuthenticationManager sharedManager] registerWithFirstName:self.firstNameTextField.text andlastName:self.lastNameTextField.text andEmail:self.emailTextField.text andPassword:self.passwordTextField.text andScheduleId:scheduleId andCompletion:^(NSString *message, NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"There was an error with our Server!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                return;
            } else {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                [[[UIAlertView alloc] initWithTitle:@"Thank you for Signin Up!" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show ];
                
//                UITabBarController *tabBarController;
//                
//                tabBarController = [[UITabBarController alloc] init];
//                [tabBarController setViewControllers:[self tabBarViewControllers]];
//                tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
//                tabBarController.navigationItem.hidesBackButton = YES;
//                tabBarController.title = [CCTAuthenticationManager sharedManager].loggedInUser.firstName;
//                
//                [self.navigationController pushViewController:tabBarController animated:YES];
                
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Make sure the passwords match!" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.schedules count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *checkIn;
    NSString *checkOut;
    NSString *title;
    CCTSchedule *schedule;
    
    schedule = [[CCTSchedule alloc] init];
    
    schedule = [self.schedules objectAtIndex:row];
    checkIn = [self  stringBetweenString:@"T" andString:@"." withstring:schedule.checkIn];
    checkOut = [self stringBetweenString:@"T" andString:@"." withstring:schedule.checkOut];
    title = [NSString stringWithFormat:@"%@ - %@", checkIn, checkOut];
    
    return title;
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

- (void)logout:(UIBarButtonItem *)sender
{
    [[CCTAuthenticationManager sharedManager] logoutWithCompletion:^(NSString *message, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"There was an error!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            return;
        }
        CCTSignInViewController *signInViewController;
        signInViewController = [[CCTSignInViewController alloc] initWithNibName:@"CCTSignInViewController" bundle:nil];
        
        [[[UIAlertView alloc] initWithTitle:@"Logged Out!" message:[NSString stringWithFormat:@"%@", message] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (NSString*)stringBetweenString:(NSString*)start andString:(NSString *)end withstring:(NSString*)str
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}

- (void)fetchAllSchedules
{
    CCTWebServicesManager *webServicesManager;
    
    webServicesManager = [[CCTWebServicesManager alloc] init];
    [webServicesManager getSchedulesWithCompletion:^(NSArray *schedules, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"There was an error with our Server!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            return;
        } else {
            self.schedules = schedules;
            [self.schedulePickerView reloadAllComponents];
        }
    }];
}

@end
