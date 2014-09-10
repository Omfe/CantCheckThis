//
//  CCTDailyCheckInsViewController.m
//  CantCheckThis
//
//  Created by Omar Gudino on 9/2/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTDailyCheckInsViewController.h"
#import "CCTWebServicesManager.h"
#import "CCTCheckIn.h"

@interface CCTDailyCheckInsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *dailyCheckInsTableView;
@property (strong, nonatomic) NSArray *dailyCheckIns;

@end

@implementation CCTDailyCheckInsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"CheckIns"];
    [self fetchDailyCheckIns];

    UIBarButtonItem *dismissListBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController:)];
    self.navigationItem.leftBarButtonItem = dismissListBarButtonItem;
}

#pragma mark - UIBarButtonItem Methods
- (void)dismissViewController:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
    
    cell = [self.dailyCheckInsTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    checkIn = [[CCTCheckIn alloc] init];
    checkIn = [self.dailyCheckIns objectAtIndex:indexPath.row];
    NSString *timeString=[self stringBetweenString:@"T" andString:@"." withstring:checkIn.checkedInAt];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", checkIn.user.firstName, timeString];
    
    return cell;
}

#pragma mark - Private Methods
- (void)fetchDailyCheckIns
{
    CCTWebServicesManager *webServicesManager;
    webServicesManager = [[CCTWebServicesManager alloc] init];
    
    [webServicesManager getDailyReportWithDate:self.date andCompletion:^(NSArray *checkIns, NSError *error)
     {
         if (error) {
             [[[UIAlertView alloc] initWithTitle:@"Error with Check Ins!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
             return;
         }
         
         self.dailyCheckIns = checkIns;
         [self.dailyCheckInsTableView reloadData];
     }
     ];
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
@end
