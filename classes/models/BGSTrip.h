//
//  BGSTrip.h
//  BGS Client
//
//  Created by Peter Todd on 12/01/2014.
//  Copyright (c) 2014 Bright Green Star. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGSTrip : NSObject
@property (strong,nonatomic) NSString *tripName;
@property (strong,nonatomic) NSString *tripType;

@property (strong,nonatomic) NSString *tripDesc;

- (id)initWithName:(NSString *)tripName tripType:(NSString*)tripType tripDesc:(NSString*)tripDesc;


@end
