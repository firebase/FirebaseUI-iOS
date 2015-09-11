//
//  FirebaseGoogleAuthHelper.m
//  FirebaseUI
//
//  Created by deast on 9/10/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import "FirebaseGoogleAuthHelper.h"

@implementation FirebaseGoogleAuthHelper

- (instancetype)initWithRef:(Firebase *)ref
                   delegate:(id<FirebaseAuthDelegate>)authDelegate {
  self = [super init];

  if (self) {
    self.ref = ref;
    self.delegate = authDelegate;
  }

  return self;
}

- (void)login {
}

- (void)logout {
}

@end