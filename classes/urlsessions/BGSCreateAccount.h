//
//  BGSCreateAccount.h
//  BGS Client
//
//  Created by Peter Todd on 12/01/2014.
//  Copyright (c) 2014 Bright Green Star. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGSCreateAccount : NSOperation<NSURLConnectionDelegate, NSURLSessionDelegate>

@property (strong,nonatomic) NSString *userEmail;
@property (strong,nonatomic) NSString *userPassword;

@property (strong,nonatomic) NSString *appServerURLAddress;


@end
