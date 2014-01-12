//
//  BGSTrip.m
//  BGS Client
//
//  Created by Peter Todd on 12/01/2014.
//  Copyright (c) 2014 Bright Green Star. All rights reserved.
//

#import "BGSTrip.h"

@implementation BGSTrip

- (id)initWithName:(NSString *)tripName tripType:(NSString*)tripType tripDesc:(NSString*)tripDesc {
    
    if ((self = [super init])) {
        self.tripName = tripName;
        self.tripType = tripType;
        self.tripDesc = tripDesc;
        
    }

    
    return self;
    
}



@end
