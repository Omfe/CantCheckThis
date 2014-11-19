//
//  CCTDatePickerViewController.m
//  CantCheckThis
//
//  Created by Omar Gudino on 9/2/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTDatePickerViewController.h"
#import "CCTCheckIn.h"
#import "CCTWebServicesManager.h"

@interface CCTDatePickerViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITableView *checkInsTableView;
@property (strong, nonatomic) NSArray *dailyCheckIns;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIView *datePickerHolder;

@end

@implementation CCTDatePickerViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    UITapGestureRecognizer *tapGestureRecognizer;
    NSDateFormatter *dateFormat;

    self.date = [NSDate date];
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    self.dateLabel.text = [dateFormat stringFromDate:[NSDate date]];
    [super viewDidLoad];
    [self fetchDailyCheckIns];
    [self initializeDatePicker];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hideDatePickerView:)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.view)
    {
        return YES;
    }
    return  NO;
}

#pragma mark - UITextFieldDelegate Methods
- (void)_hideDatePickerView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.datePickerHolder.frame = CGRectMake(0, 566, 320, 215);
                     }];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dailyCheckIns.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *identifier = @"DailyCheckInsTableViewCellIdentifier";
    CCTCheckIn *checkIn;
    
    cell = [self.checkInsTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    checkIn = [[CCTCheckIn alloc] init];
    checkIn = [self.dailyCheckIns objectAtIndex:indexPath.row];
    NSString *timeString=[self stringBetweenString:@"T" andString:@"." withstring:checkIn.checkedInAt];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", checkIn.user.firstName, timeString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UIDatePicker Action Method
- (void)updateLabel:(id)sender
{
    NSDateFormatter *dateFormat;
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    self.dateLabel.text = [dateFormat stringFromDate:self.datePicker.date];
}

#pragma mark - Action Methods
- (IBAction)chooseDateButtonWasPressed:(id)sender
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.datePickerHolder.frame = CGRectMake(0, self.view.frame.size.height/2, 320, 215);
                     }];
}

#pragma mark - Private Methods
- (void)chosedDate:(id)sender
{
    NSDateFormatter *dateFormat;
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    self.dateLabel.text = [dateFormat stringFromDate:self.datePicker.date];
    self.date = self.datePicker.date;
    
    [self fetchDailyCheckIns];
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.datePickerHolder.frame = CGRectMake(0, 566, 320, 215);
                     }];
}

- (void)fetchDailyCheckIns
{
    CCTWebServicesManager *webServicesManager;
    webServicesManager = [[CCTWebServicesManager alloc] init];
    
    [webServicesManager getDailyReportWithDate:self.date andCompletion:^(NSArray *checkIns, NSError *error)
     {
         if (error) {
             [[[UIAlertView alloc] initWithTitle:@"Daily Check Ins" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
             return;
         }
         
         self.dailyCheckIns = checkIns;
         [self.checkInsTableView reloadData];
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

- (void)initializeDatePicker
{
    NSDateFormatter *dateFormat;
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    self.datePickerHolder = [[UIView alloc] init];
    self.datePickerHolder.frame = CGRectMake(0, 800, 320, 215);
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.toolbar.barStyle   = UIBarStyleDefault;
    
    UIBarButtonItem *itemDone  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(chosedDate:)];
    UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbar.items = @[itemSpace,itemDone];
    [self.datePickerHolder addSubview:self.toolbar];
    
    CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, pickerSize.width, pickerSize.height)];
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.date = [dateFormat dateFromString:self.dateLabel.text];
    
    [self.datePicker addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventValueChanged];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    
    [self.datePickerHolder addSubview:self.datePicker];
    [self.view addSubview:self.datePickerHolder];
}
@end