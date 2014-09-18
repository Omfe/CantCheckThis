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
typedef void(^CCTWebServicesForgotPasswordCompletionBlock)(NSString *message, NSError *error);
typedef void(^CCTWebServicesGetSchedules)(NSArray *schedules, NSError *error);
typedef void(^CCTWebServicesGetUsers)(NSArray *users, NSError *error);

@interface CCTWebServicesManager : NSObject

- (void)checkInWithCompletion:(CCTWebServicesCheckInCompletionBlock)completion;
- (void)getDailyReportWithDate:(NSDate *)date andCompletion:(CCTWebServicesDailyReportCompletionBlock)completion;
- (void)forgotPasswordWithEmail:(NSString *)email andCompletion:(CCTWebServicesForgotPasswordCompletionBlock)completion;
- (void)getSchedulesWithCompletion:(CCTWebServicesGetSchedules)completion;
- (void)getUsersWithCompletion:(CCTWebServicesGetUsers)completion;

@end
