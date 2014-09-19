//
//  CCTUser.m
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTUser.h"
#import "CCTSchedule.h"

@implementation CCTUser

- (void)updateUserFromDictionary:(NSDictionary *)dictionary
{
    self.schedule = [[CCTSchedule alloc] init];
    
    self.userId = dictionary[@"id"];
    self.firstName = dictionary[@"first_name"];
    self.lastName = dictionary[@"last_name"];
    self.email = dictionary[@"email"];
    self.points = dictionary[@"points"];
    self.isAdmin = dictionary[@"is_admin"];
    self.rememberToken = dictionary[@"remember_token"];
//    self.schedule = dictionary[@"schedule"];
    [self.schedule updateFromDictionary:dictionary[@"schedule"]];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.userId forKey:@"userId"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.points forKey:@"points"];
    [encoder encodeObject:self.isAdmin forKey:@"isAdmin"];
    [encoder encodeObject:self.rememberToken forKey:@"rememberToken"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.userId = [decoder decodeObjectForKey:@"userId"];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.points = [decoder decodeObjectForKey:@"points"];
        self.isAdmin = [decoder decodeObjectForKey:@"isAdmin"];
        self.rememberToken = [decoder decodeObjectForKey:@"rememberToken"];
    }
    return self;
}

@end
