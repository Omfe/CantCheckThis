//
//  CCTUser.m
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTUser.h"

@implementation CCTUser

- (void)updateUserFromDictionary:(NSDictionary *)dictionary
{
    self.userId = dictionary[@"id"];
    self.firstName = dictionary[@"first_name"];
    self.lastName = dictionary[@"last_name"];
    self.email = dictionary[@"email"];
    self.points = dictionary[@"points"];
    self.isAdmin = dictionary[@"is_admin"];
    self.rememberToken = dictionary[@"remember_token"];
}

@end
