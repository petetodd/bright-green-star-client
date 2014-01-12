//
//  BGSCreateAccount.m
//  BGS Client
//
//  Created by Peter Todd on 12/01/2014.
//  Copyright (c) 2014 Bright Green Star. All rights reserved.
//

#import "BGSCreateAccount.h"

@implementation BGSCreateAccount
{
    NSString *_accountCreationStatus;
}



- (void)main {
    
    
    NSDate *startDate = [[NSDate alloc] init];
    float timeElapsed;
    
    NSString *accountStatusKey    = @"accountStatus";
    NSString *accountStatus    = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:accountStatusKey];
    if (accountStatus == nil)     // First ever attempt at Setting up account: set up user defaults.
    {
        NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:@"NEW", accountStatusKey, nil];
        // sync the defaults to disk
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    accountStatus    = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:accountStatusKey];

    [self createAccount:[self userEmail]];
    
    // Hold it here until a reply comes back from the operation
    // Will time out after max 5 seconds if account not setup
    while ((!_accountCreationStatus) && (timeElapsed < 5.0)) {
        NSDate *currentDate = [[NSDate alloc] init];
        timeElapsed = [currentDate timeIntervalSinceDate:startDate];
        //      NSLog(@"time elapsed: %f", timeElapsed);
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (_accountCreationStatus && ![_accountCreationStatus isEqualToString:@"CONNECTION PROBLEM"] )
    {
        [userDefaults setValue:_accountCreationStatus forKey:accountStatusKey];
        
    }
    if ([_accountCreationStatus isEqualToString:@"CREATED"] )
    {
        [userDefaults setValue:self.userEmail forKey:@"ftfID"];
        [userDefaults setValue:self.userPassword forKey:@"ftfPassword"];
    }
    if ([_accountCreationStatus isEqualToString:@"EXISTS"] )
    {
        [userDefaults setValue:self.userEmail forKey:@"ftfID"];
    }
    
    
    if ([_accountCreationStatus isEqualToString:@"CONNECTION PROBLEM"] || !_accountCreationStatus) [self cancel];
    
    if ([self isCancelled]) {
        //     NSLog(@"DEBUG FTFCreateAccount Cancelled" );
        [userDefaults setValue:@"ERROR" forKey:accountStatusKey];
    }
    
    //  NSLog(@"Operation finished");
}


#pragma mark - JSON Calls

#pragma mark  JSON Common Call Handler

-(NSURLSession*)jsonUrlSession
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    return session;
    
}

- (NSMutableURLRequest *)jsonUrlRequest:(NSString *)jsonMethod httpMethod:(NSString*)httpMethod postData:(NSData *)postData
{
   
    NSString *stringUrl =[[self appServerURLAddress] stringByAppendingString:jsonMethod];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:httpMethod];
    
    if (postData)
    {
        [request setHTTPBody:postData];
    }
    
    return request;
}


- (void)createAccount:(NSString *)userIDFtf
{

    NSError *error;
    NSString *jsonMethod = @"users";
    NSDictionary *userData = [[NSDictionary alloc] initWithObjectsAndKeys:userIDFtf, @"email",
                             self.userPassword, @"password",
                             nil];
    // Top level JSON object needs to be the user model "user"
    NSDictionary *userData2 = [[NSDictionary alloc] initWithObjectsAndKeys:userData, @"user",
                              nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:userData2 options:0 error:&error];
    
    NSMutableURLRequest *request = [self jsonUrlRequest:jsonMethod httpMethod:@"POST" postData:postData];
    [self postCreateUser:request];
    
    
}

-(NSString*)passwordGenerator:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

-(void)postCreateUser:(NSMutableURLRequest*)request
{
    __block NSString *strFTFResponse;
    
    NSURLSession *session = [self jsonUrlSession];
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (![data bytes]){
            strFTFResponse = @"CONNECTION PROBLEM";
            _accountCreationStatus = strFTFResponse;
            NSLog(@"DEBUG strFTFResponse : %@",strFTFResponse);
        } else
        {
            NSError *jsonParsingError = nil;
            if ([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                NSInteger responseStatusCode = [httpResponse statusCode];
                NSLog(@"DEBUG responseStatusCode  : %li",(long)responseStatusCode );
                
                // 422 = Email already exists
                if (responseStatusCode == 422)
                {
                    _accountCreationStatus = @"EXISTS";
                }
                // 201 = Saved new account
                if (responseStatusCode == 201)
                {
                    _accountCreationStatus = @"CREATED";
                }

            }else
            {
                _accountCreationStatus = Nil;
            }
            
            
            NSDictionary *urlResponseDataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSLog(@"DEBUG status code urlResponseDataDict : %@",[urlResponseDataDict objectForKey:@"status code"]);
            
            NSLog(@"DEBUG ORIGINAL dataAsString %@", [NSString stringWithUTF8String:[data bytes]]);

            NSDictionary *responseDataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSLog(@"DEBUG email responseDataDict : %@",[responseDataDict objectForKey:@"email"]);

            
        }
    }];
    [postDataTask resume];
    
}





@end


