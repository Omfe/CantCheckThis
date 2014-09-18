//
//  CCTAuthenticationManager.h
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTUser.h"

extern NSString *CCTServerError;

typedef void(^CCTAuthenticationLoginCompletionBlock)(NSString *message, NSError *error);
typedef void(^CCTAuthenticationLogoutCompletionBlock)(NSString *message, NSError *error);
typedef void(^CCTAuthenticationResetPasswordCompletionBlock)(NSString *message, NSError *error);
typedef void(^CCTAuthenticationRegisterCompletionBlock)(NSString *message, NSError *error);
typedef void(^CCTAuthenticationUpdateUserCompletionBlock)(NSString *message, NSError *error);

@interface CCTAuthenticationManager : NSObject

@property (strong, nonatomic) CCTUser *loggedInUser;

+ (CCTAuthenticationManager *)sharedManager;

- (void)loginWithEmail:(NSString *)email withPassword:(NSString *)password andCompletion:(CCTAuthenticationLoginCompletionBlock)completion;
- (void)logoutWithCompletion:(CCTAuthenticationLogoutCompletionBlock)completion;
- (void)resetPasswordWithOldPassword:(NSString *)oldPassword withNewPassword:(NSString *)newPassword andCompletion:(CCTAuthenticationResetPasswordCompletionBlock)completion;
- (void)registerWithFirstName:(NSString *)firstName andlastName:(NSString *)lastName andEmail:(NSString *)email andPassword:(NSString *)password andScheduleId:(NSString *)scheduleId andCompletion:(CCTAuthenticationRegisterCompletionBlock)completion;
- (void)updateUserWithFirstName:(NSString *)firstName andlastName:(NSString *)lastName andEmail:(NSString *)email andScheduleId:(NSString *)scheduleId andCompletion:(CCTAuthenticationUpdateUserCompletionBlock)completion;

@end
