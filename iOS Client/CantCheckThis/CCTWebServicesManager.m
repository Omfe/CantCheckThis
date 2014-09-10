//
//  CCTWebServicesManager.m
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTWebServicesManager.h"
#import "CCTUser.h"
#import "CCTAuthenticationManager.h"
#import "CCTCheckIn.h"
#import "CCTSchedule.h"

#define kServerURL @"http://localhost:3000"

@implementation CCTWebServicesManager

#pragma mark - Public Methods
- (void)checkInWithCompletion:(CCTWebServicesCheckInCompletionBlock)completion;
{
    NSMutableURLRequest *urlRequest;
    NSURL *url;
    NSString *urlString;
    NSString *headerValue;
    
    urlString = [kServerURL stringByAppendingPathComponent:@"checkin"];
    url = [NSURL URLWithString:urlString];
    urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    headerValue = [NSString stringWithFormat:@"Token token=%@", [[CCTAuthenticationManager sharedManager] loggedInUser].rememberToken];
    [urlRequest setValue:headerValue forHTTPHeaderField:@"Authorization"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {
        NSDictionary *responseDictionary;
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([(NSHTTPURLResponse *)urlResponse statusCode] == 200) {
            
            if (completion) {
                completion(responseDictionary[@"report"], nil);
            }
            return;
        }
        
        if (completion) {
            error = [[NSError alloc] initWithDomain:CCTServerError code:422 userInfo:@{ NSLocalizedDescriptionKey: @"Wait until tommorow" }];
            completion(responseDictionary[@"status"], error);

        }
    }];

}

- (void)getDailyReportWithDate:(NSDate *)date andCompletion:(CCTWebServicesDailyReportCompletionBlock)completion
{
    NSMutableURLRequest *urlRequest;
    NSURL *url;
    NSString *urlString;
    NSData *bodyData;
    NSDictionary *bodyDictionary;
    NSString *headerValue;
    NSDateFormatter *dateFormat;
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    urlString = [kServerURL stringByAppendingPathComponent:@"daily_report"];
    url = [NSURL URLWithString:urlString];
    urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    headerValue = [NSString stringWithFormat:@"Token token=%@", [[CCTAuthenticationManager sharedManager] loggedInUser].rememberToken];
    [urlRequest setValue:headerValue forHTTPHeaderField:@"Authorization"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"content-type"];
    bodyDictionary = @{ @"date": [dateFormat stringFromDate:date] };
    bodyData = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:nil];
    [urlRequest setHTTPBody:bodyData];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {
        NSDictionary *responseDictionary;
        NSMutableArray *checkIns;
        CCTCheckIn *checkIn;
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([(NSHTTPURLResponse *)urlResponse statusCode] == 200) {
            checkIns = [[NSMutableArray alloc] init];
            for (NSDictionary *dictionary in responseDictionary) {
                checkIn = [[CCTCheckIn alloc] init];
                [checkIn updateFromDictionary:dictionary];
                [checkIns addObject:checkIn];
            }
            
            if (completion) {
                completion(checkIns, nil);
            }
            return;
        }
        
        if (completion) {
            error = [[NSError alloc] initWithDomain:CCTServerError code:422 userInfo:@{ NSLocalizedDescriptionKey: @"There was a problem with the date" }];
            completion(responseDictionary[@"status"], error);
            
        }
    }];

}

- (void)forgotPasswordWithEmail:(NSString *)email andCompletion:(CCTWebServicesForgotPasswordCompletionBlock)completion
{
    NSMutableURLRequest *urlRequest;
    NSURL *url;
    NSString *urlString;
    NSData *bodyData;
    NSDictionary *bodyDictionary;
    
    urlString = [kServerURL stringByAppendingPathComponent:@"forgot_password"];
    url = [NSURL URLWithString:urlString];
    urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"content-type"];
    bodyDictionary = @{ @"email": email };
    bodyData = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:nil];
    [urlRequest setHTTPBody:bodyData];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {
        NSDictionary *responseDictionary;
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([(NSHTTPURLResponse *)urlResponse statusCode] == 200) {
            if (completion) {
                completion(responseDictionary[@"status"], nil);
            }
            return;
        }
        
        if (completion) {
            error = [[NSError alloc] initWithDomain:CCTServerError code:422 userInfo:@{ NSLocalizedDescriptionKey: @"Incorrect email or password" }];
            completion(responseDictionary[@"status"], error);
        }
    }];
}

- (void)getSchedulesWithCompletion:(CCTWebServicesGetSchedules)completion
{
    NSMutableURLRequest *urlRequest;
    NSURL *url;
    NSString *urlString;
    
    urlString = [kServerURL stringByAppendingPathComponent:@"all_schedules"];
    url = [NSURL URLWithString:urlString];
    urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {
        NSDictionary *responseDictionary;
        NSMutableArray *schedules;
        CCTSchedule *schedule;
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([(NSHTTPURLResponse *)urlResponse statusCode] == 200) {
            schedules = [[NSMutableArray alloc] init];
            for (NSDictionary *dictionary in responseDictionary) {
                schedule = [[CCTSchedule alloc] init];
                [schedule updateFromDictionary:dictionary];
                [schedules addObject:schedule];
            }
            
            if (completion) {
                completion(schedules, nil);
            }
            return;
        }
        
        if (completion) {
            error = [[NSError alloc] initWithDomain:CCTServerError code:422 userInfo:@{ NSLocalizedDescriptionKey: @"Wait until tommorow" }];
            completion(responseDictionary[@"status"], error);
            
        }
    }];
}

@end
