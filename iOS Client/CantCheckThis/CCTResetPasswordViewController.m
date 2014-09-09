//
//  CCTResetPasswordViewController.m
//  CantCheckThis
//
//  Created by Omar Gudino on 9/5/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTResetPasswordViewController.h"
#import "CCTAuthenticationManager.h"

@interface CCTResetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *theNewPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPasswordTextField;



@end

@implementation CCTResetPasswordViewController

- (void)viewDidLoad
{
    UITapGestureRecognizer *tapGestureRecognizer;
    
    [super viewDidLoad];
    [self setTitle:@"Reset Password"];
    UIBarButtonItem *dismissViewBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController:)];
    self.navigationItem.leftBarButtonItem = dismissViewBarButtonItem;
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hideTextView:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.oldPasswordTextField.secureTextEntry = YES;
    self.theNewPasswordTextField.secureTextEntry = YES;
    self.confirmNewPasswordTextField.secureTextEntry = YES;
}

#pragma mark - UITextFieldDelegate Methods
- (void)_hideTextView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.oldPasswordTextField resignFirstResponder];
    [self.theNewPasswordTextField resignFirstResponder];
    [self.confirmNewPasswordTextField resignFirstResponder];
}

- (IBAction)changePasswordButtonWasPressed:(id)sender
{
    if ([self.theNewPasswordTextField.text isEqualToString:self.confirmNewPasswordTextField.text]) {
        [[CCTAuthenticationManager sharedManager] resetPasswordWithOldPassword:self.oldPasswordTextField.text withNewPassword:self.confirmNewPasswordTextField.text andCompletion:^(NSString *message, NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"There was an error!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                return;
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Password Reset!" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show ];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Confirm the New Password Correctly" message:@"Did not match" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
}

- (void)dismissViewController:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view setFrame:CGRectMake(0,-40,320,460)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view setFrame:CGRectMake(0,0,320,460)];
}

@end
