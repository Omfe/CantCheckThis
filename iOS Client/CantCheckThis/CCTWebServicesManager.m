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

#define kServerURL @"http://localhost:3000"

@implementation CCTWebServicesManager

- (void)checkInWithCompletion:(CCTWebServicesCheckInCompletionBlock)completion;
{
    NSMutableURLRequest *urlRequest;
    NSURL *url;
    NSString *urlString;
    //NSData *bodyData;
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

@end
