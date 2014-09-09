//
//  CCTSchedule.m
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTSchedule.h"

@implementation CCTSchedule

- (void)updateFromDictionary:(NSDictionary *)dictionary
{
    self.scheduleId = dictionary[@"id"];
    self.checkIn = dictionary[@"check_in"];
    self.checkOut = dictionary[@"check_out"];
}

@end
