//
//  CCTUserProfileViewController.m
//  CantCheckThis
//
//  Created by Omar Gudino on 9/17/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTUserProfileViewController.h"
#import "CCTSchedule.h"
#import "CCTWebServicesManager.h"
#import "CCTAuthenticationManager.h"
#import "CCTResetPasswordViewController.h"

@interface CCTUserProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *schedulePickerView;
@property (weak, nonatomic) IBOutlet UIScrollView *userProfileScrollView;
@property (nonatomic) NSArray *fieldArray;
@property (strong, nonatomic) NSArray *schedules;

@end

@implementation CCTUserProfileViewController

- (void)viewDidLoad
{
    UITapGestureRecognizer *tapGestureRecognizer;
    
    [scroller setScrollEnabled:YES];
    [super viewDidLoad];
    [self fetchAllSchedules];
    [self setTitle:@"User Profile"];
    self.fieldArray = [NSArray arrayWithObjects: self.firstNameTextField, self.lastNameTextField, self.emailTextField,  nil];
    
    UIBarButtonItem *dismissViewBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController:)];
    UIBarButtonItem *updateUserBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)];
    self.navigationItem.leftBarButtonItem = dismissViewBarButtonItem;
    self.navigationItem.rightBarButtonItem = updateUserBarButtonItem;
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hideTextView:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.firstNameTextField.text = [CCTAuthenticationManager sharedManager].loggedInUser.firstName;
    self.lastNameTextField.text = [CCTAuthenticationManager sharedManager].loggedInUser.lastName;
    self.emailTextField.text = [CCTAuthenticationManager sharedManager].loggedInUser.email;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.firstNameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.firstNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.lastNameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.lastNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
}
- (IBAction)resetPasswordWasPressed:(id)sender
{
    CCTResetPasswordViewController *resetPasswordViewController;
    UINavigationController *navigationController;
    
    resetPasswordViewController = [[CCTResetPasswordViewController alloc] initWithNibName:@"CCTResetPasswordViewController" bundle:nil];
    navigationController = [[UINavigationController alloc] initWithRootViewController:resetPasswordViewController];
    [self.navigationController pushViewController:resetPasswordViewController animated:YES];
}

- (IBAction)logoutButtonWasPressed:(id)sender
{
    [[CCTAuthenticationManager sharedManager] logoutWithCompletion:^(NSString *message, NSError *error) {
//        if (error) {
//            [[[UIAlertView alloc] initWithTitle:@"Logout" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
//            return;
//        }
        [[[UIAlertView alloc] initWithTitle:@"Logout" message:[NSString stringWithFormat:@"%@", message] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        [self dismissViewControllerAnimated:YES completion:nil];
        [(UINavigationController *)self.presentingViewController  popViewControllerAnimated:NO];
    }
     ];
    NSLog(@"I am %@", self);
}

- (void)viewDidLayoutSubviews
{
    [scroller setContentSize:CGSizeMake(320, 701)];
}

#pragma mark - UITextFieldDelegate Methods
- (void)_hideTextView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect absoluteframe = [textField convertRect:textField.frame toView:[UIApplication sharedApplication].keyWindow];
    [self.userProfileScrollView scrollRectToVisible:absoluteframe animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    NSUInteger index = [self.fieldArray indexOfObject:textField];
    if (index == NSNotFound || index + 1 == self.fieldArray.count) return NO;
    
    id nextField = [self.fieldArray objectAtIndex:index + 1];
    textField = nextField;
    [nextField becomeFirstResponder];
    
    return NO;
}

#pragma mark - UIBarButtonItem Methods
- (void)dismissViewController:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneEditing:(UIBarButtonItem *) sender
{
    [self updateUser];
}

#pragma mark - UIPickerViewDataSource Methods
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.schedules count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark - UIPickerViewDelegate Methods
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

#pragma mark - Private Methods
- (void)fetchAllSchedules
{
    CCTWebServicesManager *webServicesManager;
    
    webServicesManager = [[CCTWebServicesManager alloc] init];
    [webServicesManager getSchedulesWithCompletion:^(NSArray *schedules, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Fetch Schedules!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            return;
        } else {
            self.schedules = schedules;
            [self.schedulePickerView reloadAllComponents];
            [self.schedulePickerView selectRow:[self currentUserSchedule] inComponent:0 animated:YES];
        }
    }];
}

- (void)updateUser
{
    if ([self validatedInput]) {
        NSString *scheduleId;
        CCTSchedule *selectedSchedule;
        
        selectedSchedule = [[CCTSchedule alloc] init];
        selectedSchedule = [self.schedules  objectAtIndex:[self. schedulePickerView selectedRowInComponent:0]];
        scheduleId = [NSString stringWithFormat:@"%@", selectedSchedule.scheduleId];
        
        [[CCTAuthenticationManager sharedManager] updateUserWithFirstName:self.firstNameTextField.text andlastName:self.lastNameTextField.text andEmail:self.emailTextField.text andScheduleId:scheduleId andCompletion:^(NSString *message, NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"User Update" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                return;
            } else {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                [[[UIAlertView alloc] initWithTitle:@"User Update" message:[NSString stringWithFormat:@"%@ your changes were made", self.firstNameTextField.text] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show ];
            }
        }];
    }
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

- (BOOL)validatedInput
{
    NSString *email = self.emailTextField.text;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL myStringMatchesRegEx=[emailTest evaluateWithObject:email];
    
    if (self.firstNameTextField.text.length == 0 || self.lastNameTextField.text.length == 0 ||self.emailTextField.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Register" message:@"Fill all the text fields please" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show ];
        return NO;
    } else if (!myStringMatchesRegEx) {
        [[[UIAlertView alloc] initWithTitle:@"Register" message:@"Enter a valid email id." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show ];
        return NO;
    } else {
        return YES;
    }
}

- (NSInteger)currentUserSchedule
{
    NSInteger index = 0;
    
    for (CCTSchedule *schedule in self.schedules) {
        if ([[CCTAuthenticationManager sharedManager].loggedInUser.schedule.scheduleId isEqualToNumber:schedule.scheduleId]) {
            return index;
        }
        index++;
    }
    return  0;
}

@end
