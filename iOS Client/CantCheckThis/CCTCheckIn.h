//
//  CCTCheckIn.h
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCTUser.h"

@interface CCTCheckIn : NSObject

@property (strong, nonatomic) NSNumber *checkInId;
@property (strong, nonatomic) NSString *checkedInAt;
@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) CCTUser *user;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

@end
