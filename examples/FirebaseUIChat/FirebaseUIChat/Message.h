//
//  Message.h
//  FirebaseUIChat
//
//  Created by Mike Mcdonald on 8/20/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *text;

- (instancetype)initWithName:(NSString *)name andText:(NSString *)text;

@end
