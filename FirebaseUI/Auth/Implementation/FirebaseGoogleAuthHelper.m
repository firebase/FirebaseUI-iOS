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
                   delegate:
                       (UIViewController<FirebaseAuthDelegate> *)authDelegate {
  self = [super init];

  if (self) {
    self.ref = ref;
    self.delegate = authDelegate;
  }

  return self;
}

- (instancetype)initWithRef:(Firebase *)ref
                   delegate:
                       (UIViewController<FirebaseAuthDelegate> *)authDelegate
             signInDelegate:(id<GIDSignInDelegate>)signInDelegate
                 uiDelegate:(id<GIDSignInUIDelegate>)uiDelegate {
  self = [super init];
  if (self) {
    self.ref = ref;
    self.delegate = authDelegate;
    [GIDSignIn sharedInstance].delegate = signInDelegate;
    [GIDSignIn sharedInstance].uiDelegate = uiDelegate;
  }
  return self;
}

- (void)login {
  [[GIDSignIn sharedInstance] signIn];
}

- (void)logout {
  [[GIDSignIn sharedInstance] signOut];
}

- (void)signIn:(GIDSignIn *)signIn
    didSignInForUser:(GIDGoogleUser *)user
           withError:(NSError *)error {
  [self.ref authWithOAuthProvider:@"google"
                            token:user.authentication.accessToken
              withCompletionBlock:^(NSError *error, FAuthData *authData) {

                if (error) {
                  [self.delegate onError:error];
                  return;
                } else {
                  [self.delegate onAuthStageChange:authData];
                  return;
                }

              }];
}

@end