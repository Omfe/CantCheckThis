//
//  CCTWebServicesManager.h
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

@class CCTUser;
@class CCTCheckIn;

typedef void(^CCTWebServicesCheckInCompletionBlock)(NSString *message, NSError *error);
typedef void(^CCTWebServicesDailyReportCompletionBlock)(NSArray *checkIns, NSError *error);

@interface CCTWebServicesManager : NSObject

- (void)checkInWithCompletion:(CCTWebServicesCheckInCompletionBlock)completion;
- (void)getDailyReportWithDate:(NSDate *)date andCompletion:(CCTWebServicesDailyReportCompletionBlock)completion;

@end
