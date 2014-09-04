//
//  CCTAuthenticationManager.m
//  CantCheckThis
//
//  Created by Omar Gudino on 8/27/14.
//  Copyright (c) 2014 Omar Gudino. All rights reserved.
//

#import "CCTAuthenticationManager.h"
#import "CCTUser.h"

#define kServerURL @"http://localhost:3000"

NSString *CCTServerError = @"CCTServerError";

@interface CCTAuthenticationManager ()

@end

@implementation CCTAuthenticationManager

static CCTAuthenticationManager *_sharedAuthenticationManager = nil;
+ (CCTAuthenticationManager *)sharedManager
{
    if (!_sharedAuthenticationManager) {
        _sharedAuthenticationManager = [[CCTAuthenticationManager alloc] init];
    }
    return _sharedAuthenticationManager;
}

#pragma mark - Public Methods
- (void)loginWithEmail:(NSString *)email withPassword:(NSString *)password andCompletion:(CCTAuthenticationLoginCompletionBlock)completion
{
    NSMutableURLRequest *urlRequest;
    NSURL *url;
    NSString *urlString;
    NSData *bodyData;
    NSDictionary *bodyDictionary;
    
    urlString = [kServerURL stringByAppendingPathComponent:@"login"];
    url = [NSURL URLWithString:urlString];
    urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"content-type"];
    bodyDictionary = @{ @"email": email, @"password": password };
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
        
        if ([(NSHTTPURLResponse *)urlResponse statusCode] == 201) {
            if (!self.loggedInUser) {
                self.loggedInUser = [[CCTUser alloc] init];
            }
            [self.loggedInUser updateUserFromDictionary:responseDictionary];
            
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

- (void)logoutWithCompletion:(CCTAuthenticationLogoutCompletionBlock)completion
{
    NSMutableURLRequest *urlRequest;
    NSURL *url;
    NSString *urlString;
    NSString *headerValue;
    
    urlString = [kServerURL stringByAppendingPathComponent:@"logout"];
    url = [NSURL URLWithString:urlString];
    urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"DELETE"];
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
                completion(responseDictionary[@"status"], nil);
            }
            return;
        }
        
        if (completion) {
            error = [[NSError alloc] initWithDomain:CCTServerError code:422 userInfo:@{ NSLocalizedDescriptionKey: @"Exited" }];
            completion(responseDictionary[@"status"], error);
            
        }
    }];
}

@end
