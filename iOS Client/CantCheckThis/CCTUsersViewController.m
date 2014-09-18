//
//  CCTUsersViewController.m
//  CantCheckThis
//
//  Created by Omar Gudino on 9/11/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTUsersViewController.h"
#import "CCTUser.h"
#import "CCTWebServicesManager.h"

@interface CCTUsersViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *usersTableView;
@property (strong, nonatomic) NSArray *users;

@end

@implementation CCTUsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Users"];
    [self fetchUsers];
    
    UIBarButtonItem *dismissListBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController:)];
    self.navigationItem.leftBarButtonItem = dismissListBarButtonItem;
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *identifier = @"DailyCheckInsTableViewCellIdentifier";
    CCTUser *user;
    
    cell = [self.usersTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    user = [[CCTUser alloc] init];
    user = [self.users objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@      :      %@", user.firstName, user.points];
    
    return cell;
}

#pragma mark - UIBarButtonItem Methods
- (void)dismissViewController:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)fetchUsers
{
    CCTWebServicesManager *webServicesManager;
    webServicesManager = [[CCTWebServicesManager alloc] init];
    
    [webServicesManager getUsersWithCompletion:^(NSArray *users, NSError *error)
     {
         if (error) {
             [[[UIAlertView alloc] initWithTitle:@"Users" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
             return;
         }
         
         self.users = users;
         [self.usersTableView reloadData];
     }];
}

//#pragma mark - Public Methods
//- (void)reloadUsers
//{
//    [self fetchUsers];
//}


@end
