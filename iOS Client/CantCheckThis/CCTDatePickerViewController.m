//
//  CCTDatePickerViewController.m
//  CantCheckThis
//
//  Created by Omar Gudino on 9/2/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTDatePickerViewController.h"
#import "CCTDailyCheckInsViewController.h"

@interface CCTDatePickerViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;

@end

@implementation CCTDatePickerViewController

- (void)viewDidLoad
{
    UITapGestureRecognizer *tapGestureRecognizer;
    UIDatePicker *datePicker;
    
    [super viewDidLoad];
    
    datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.dateTextField setInputView:datePicker];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hideDatePickerView:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)_hideDatePickerView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.dateTextField resignFirstResponder];
}

-(void)updateTextField:(id)sender
{
    NSDateFormatter *dateFormat;
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    UIDatePicker *picker = (UIDatePicker*)self.dateTextField.inputView;
    self.dateTextField.text = [dateFormat stringFromDate:picker.date];
}

- (IBAction)okButtonWasPressed:(id)sender
{
    NSDateFormatter *dateFormatter;
    NSDate *dateFromString;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    dateFromString = [dateFormatter dateFromString:self.dateTextField.text];
    
    if (dateFromString == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Select a Valid Date!" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    } else {
        CCTDailyCheckInsViewController *dailyCheckInsViewController;
        UINavigationController *navigationController;
        
        dailyCheckInsViewController = [[CCTDailyCheckInsViewController alloc] initWithNibName:@"CCTDailyCheckInsViewController" bundle:nil];
        navigationController = [[UINavigationController alloc] initWithRootViewController:dailyCheckInsViewController];
        dailyCheckInsViewController.date = dateFromString;
        [self presentViewController:navigationController animated:YES completion:nil];
       // [self.navigationController presentViewController:dailyCheckInsViewController animated:YES completion:nil];
//        [self.navigationController pushViewController:dailyCheckInsViewController animated:YES];
    }
}
@end