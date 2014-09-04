//
//  CCTUser.h
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCTUser : NSObject

@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSNumber *points;
@property (strong, nonatomic) NSNumber *isAdmin;
@property (strong, nonatomic) NSString *rememberToken;
@property (strong, nonatomic) NSString *encryptedPassword;

- (void)updateUserFromDictionary:(NSDictionary *)dictionary;

@end
