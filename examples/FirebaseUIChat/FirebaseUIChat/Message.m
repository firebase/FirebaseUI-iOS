//
//  Message.m
//  FirebaseUIChat
//
//  Created by Mike Mcdonald on 8/20/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)init;
{
    return [self initWithName:@"" andMessage:@""];
}

-(instancetype)initWithName:(NSString *)name andMessage:(NSString *)message;
{
    self = [super init];
    if (self) {
        self.name = name;
        self.message = message;
    }
    return self;
}

@end
