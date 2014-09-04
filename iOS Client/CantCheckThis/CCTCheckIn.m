//
//  CCTCheckIn.m
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTCheckIn.h"
#import "CCTUser.h"

@implementation CCTCheckIn

- (void)updateFromDictionary:(NSDictionary *)dictionary
{
    self.user = [[CCTUser alloc] init];
    
    self.checkInId = dictionary[@"id"];
    self.checkedInAt = dictionary[@"checked_in_at"];
    [self.user updateUserFromDictionary:dictionary[@"user"]];
}

@end