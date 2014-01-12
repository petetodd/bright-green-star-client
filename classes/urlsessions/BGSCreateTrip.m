//
//  BGSCreateTrip.m
//  BGS Client
//
//  Created by Peter Todd on 12/01/2014.
//  Copyright (c) 2014 Bright Green Star. All rights reserved.
//

#import "BGSCreateTrip.h"

@implementation BGSCreateTrip
{
    NSString *_routePostStatus;
    NSString *_sharingRef;
}


- (void)main {
    
    NSDate *startDate = [[NSDate alloc] init];
    float timeElapsed;
    NSString *accountStatusKey    = @"accountStatus";
    NSString *accountStatus    = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:accountStatusKey];
    
    
    if ([accountStatus isEqualToString:@"ERROR"])
    {
        // There was a ERROR in creating / accessing the user account.  Cancel the post
        [self cancel];
    } else
    {
      
        [self postToBGS];
        
        // Hold it here until a reply comes back from the operation
        while ((!_routePostStatus) && (timeElapsed < 5)) {
            NSDate *currentDate = [[NSDate alloc] init];
            
            timeElapsed = [currentDate timeIntervalSinceDate:startDate];
        }
        
    }
    
    if ([self isCancelled]) {
        NSLog(@"Post operation cancelled");
    }
    
    
}




-(void)postTripToBGS:(NSMutableURLRequest*)request
{
    //    NSError *error;
    NSURLSession *session = [self jsonUrlSession];

    // Note: passing Nil to completionHandler causing our custom completion handler to run (we have already set delegate to self).
    
    NSURLSessionDataTask *postDataTask2 = [session dataTaskWithRequest:request completionHandler:Nil];
    [postDataTask2 resume];
}


- (void)postToBGS
{
    NSString *jsonMethod = @"trips.json";
    
    NSError *error;
    
    
    NSString *strTripType = [self.selectedTrip tripType
                             ];
    if (!strTripType){
        strTripType = @"Missing";
    }
    
    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys:[self.selectedTrip tripName], @"name",
                             [self.selectedTrip tripDesc], @"content",
                             strTripType, @"typetrip",
                             nil];
    // Top level JSON object needs to be the trip model "trip" which has properties defined by mapData.
    NSDictionary *mapData2 = [[NSDictionary alloc] initWithObjectsAndKeys:mapData, @"trip",
                              nil];
    
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData2 options:0 error:&error];
    
    NSMutableURLRequest *request = [self jsonUrlRequest:jsonMethod httpMethod:@"POST" postData:postData];
    [self postTripToBGS:request];
    
    
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
    NSString *appServer = [self appServerURLAddress];
    
    NSString *stringUrl =[appServer stringByAppendingString:jsonMethod];
    
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


#pragma mark - URLSession Delegates

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    NSLog(@"DEBUG responseStatusCode  : %li",(long)responseStatusCode );
    if (responseStatusCode == 201) _routePostStatus=@"CREATED";
    
    NSDictionary *headerDictionary;
    headerDictionary = [httpResponse allHeaderFields] ;
    for (int i = 0; i< headerDictionary.count;i++){
        NSString *keyString = [[headerDictionary allKeys] objectAtIndex:i];
        NSLog(@"Keystring : %@",keyString);
        NSLog(@"DEBUG keyString value : %@",[headerDictionary valueForKey:keyString]);
        
    }
    
    
    NSLog(@"### handler 1");
    NSLog(@"DEBUG Response:%@ ", response);
    //    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
    NSDictionary *reponseHeaders = [httpResponse allHeaderFields];
    NSLog(@"DEBUG location : %@",[reponseHeaders objectForKey:@"Location"]);
    
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if (![data bytes]){
        return;
    }else
    {
        NSError *jsonParsingError = nil;
        
        NSDictionary *urlResponseDataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        _sharingRef = [[urlResponseDataDict valueForKey:@"id"] stringValue];
        
    }
    
    NSLog(@"### handler 2");
    
    //    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    NSLog(@"Received String %@",str);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"DEBUG  didCompleteWithError");
    
    if(error == nil)
    {
        
        _routePostStatus = [_routePostStatus stringByAppendingString:@"_COMPLETE"];
        
        NSLog(@"DEBUG didCompleteWithError NIL ERROR. _routePostStatus : %@",_routePostStatus);
        
        // This is where you can call manageobject operations etc.. thAT need to be done on the main thread:
        //if ([_routePostStatus isEqualToString:@"CREATED_COMPLETE"])[self performSelectorOnMainThread:@selector(mocUpdateMap) withObject:nil waitUntilDone:NO];
    }
    else
    {
        NSString *alertText;
        UIAlertView *alertDialog;
        
        alertText = [NSString stringWithFormat:
                     @"Please try again.  If the error persists please contact FTF support. : domain = %@, code = %ld",
                     error.domain, (long)error.code];
        alertDialog = [[UIAlertView alloc]
                       initWithTitle: @"Error Sharing Route" message:alertText delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        [alertDialog show];
    }
    
    
}

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSLog(@"### handler 5");
    //   NSLog(@"didReceiveChallenge");
    
    NSString *ftfID    = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"ftfID"];
    NSString *ftfPassword    = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"ftfPassword"];
    
    NSString *user = ftfID;
    NSString *password = ftfPassword;
    
    NSLog(@"DEBUG session challenge user = %@", ftfID);
    NSLog(@"DEBUG session challenge password = %@", ftfPassword);

    // should prompt for a password in a real app but we will hard code this test
    NSURLCredential *secretHandshake = [NSURLCredential credentialWithUser:user password:password persistence:NSURLCredentialPersistenceForSession];
    
    // use block
    completionHandler(NSURLSessionAuthChallengeUseCredential,secretHandshake);
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    //   NSLog(@"didReceiveChallenge");
    
    NSString *ftfID    = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"ftfID"];
    NSString *ftfPassword    = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"ftfPassword"];

    
    NSString *user = ftfID;
    NSString *password = ftfPassword;
    NSLog(@"DEBUG task challenge user = %@", ftfID);
    NSLog(@"DEBUG task challenge password = %@", ftfPassword);
    
    // should prompt for a password in a real app but we will hard code this test
    NSURLCredential *secretHandshake = [NSURLCredential credentialWithUser:user password:password persistence:NSURLCredentialPersistenceForSession];
    
    // use block
    completionHandler(NSURLSessionAuthChallengeUseCredential,secretHandshake);
    
}



@end
