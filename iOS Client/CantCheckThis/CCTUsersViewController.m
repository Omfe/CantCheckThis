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
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation CCTUsersViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchUsers];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.usersTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *dismissListBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController:)];
    self.navigationItem.leftBarButtonItem = dismissListBarButtonItem;
}

#pragma mark - UITableViewDataSource Methods
- (void)refreshTable
{
    [self fetchUsers];
    [self.refreshControl endRefreshing];
}

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
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16.0f];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    [indicator setCenter:self.view.center];
    
    [webServicesManager getUsersWithCompletion:^(NSArray *users, NSError *error)
     {
         if (error) {
             [[[UIAlertView alloc] initWithTitle:@"Users" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
             return;
         }
         
         self.users = users;
         [indicator removeFromSuperview];
         [self.usersTableView reloadData];
     }];
}
@end
