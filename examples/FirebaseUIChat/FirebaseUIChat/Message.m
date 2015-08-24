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
{ return [self initWithName:@"" andText:@""]; }

- (instancetype)initWithName:(NSString *)name andText:(NSString *)text;
{
  self = [super init];
  if (self) {
    self.name = name;
    self.text = text;
  }
  return self;
}

@end
