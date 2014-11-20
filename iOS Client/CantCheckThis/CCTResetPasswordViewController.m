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
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (nonatomic) NSArray *fieldArray;

@end

@implementation CCTResetPasswordViewController

- (void)viewDidLoad
{
    UITapGestureRecognizer *tapGestureRecognizer;
    
    [super viewDidLoad];
    [self setTitle:@"RESET PASSWORD"];
    self.fieldArray = [NSArray arrayWithObjects: self.oldPasswordTextField, self.theNewPasswordTextField,  nil];

    UIBarButtonItem *dismissViewBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController:)];
    self.navigationItem.leftBarButtonItem = dismissViewBarButtonItem;
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hideTextView:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.oldPasswordTextField.secureTextEntry = YES;
    self.oldPasswordTextField.layer.borderColor = [[UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0] CGColor];
    self.oldPasswordTextField.layer.borderWidth=1.0;
    self.theNewPasswordTextField.secureTextEntry = YES;
    self.theNewPasswordTextField.layer.borderColor = [[UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0] CGColor];
    self.theNewPasswordTextField.layer.borderWidth=1.0;
//    self.changePasswordButton.layer.borderColor = [[UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0] CGColor];
//    self.changePasswordButton.layer.borderWidth=1.0;
    
}

#pragma mark - UITextFieldDelegate Methods
- (void)_hideTextView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.oldPasswordTextField resignFirstResponder];
    [self.theNewPasswordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    NSUInteger index = [self.fieldArray indexOfObject:textField];
    if (index == NSNotFound || index + 1 == self.fieldArray.count){
        [self resetPassword];
        return NO;
    }
    
    id nextField = [self.fieldArray objectAtIndex:index + 1];
    textField = nextField;
    [nextField becomeFirstResponder];
    
    return NO;
}

- (IBAction)changePasswordButtonWasPressed:(id)sender
{
    [self resetPassword];
}

- (void)dismissViewController:(UIBarButtonItem *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)validatedInput
{
    
    if (self.theNewPasswordTextField.text.length == 0 || self.oldPasswordTextField.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Register" message:@"Fill all the text fields please" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show ];
        return NO;
    } else {
        return YES;
    }
}

- (void)resetPassword
{
    if ([self validatedInput]) {
        [[CCTAuthenticationManager sharedManager] resetPasswordWithOldPassword:self.oldPasswordTextField.text withNewPassword:self.theNewPasswordTextField.text andCompletion:^(NSString *message, NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"Password Reset" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                return;
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Password Reset" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show ];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

@end
