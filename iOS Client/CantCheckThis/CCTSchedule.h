//
//  CCTSchedule.h
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCTSchedule : NSObject

@property (strong, nonatomic) NSNumber *scheduleId;
@property (strong, nonatomic) NSString *checkIn;
@property (strong, nonatomic) NSString *checkOut;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

@end
