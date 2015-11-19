//
//  FirebaseGoogleAuthHelper.m
//  FirebaseUI
//
//  Created by deast on 9/10/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import "FirebaseGoogleAuthHelper.h"

@implementation FirebaseGoogleAuthHelper

- (instancetype)initWithRef:(Firebase *)ref authDelegate:(id<FirebaseAuthDelegate>)authDelegate uiDelegate:(UIViewController<GIDSignInUIDelegate> *)uiDelegate {
  self = [super initWithRef:ref authDelegate:authDelegate];
  if (self) {
    self.provider = kGoogleAuthProvider;
    [self configureProvider];
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = uiDelegate;
  }
  return self;
}

- (void)configureProvider {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
  NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];
  NSString *reversedClientId =[plist objectForKey:@"REVERSED_CLIENT_ID"];
  BOOL clientIdExists = [plist objectForKey:@"CLIENT_ID"] != nil;
  BOOL reversedClientIdExists = reversedClientId != nil;
  
  if (!(clientIdExists && reversedClientIdExists)) {
    [NSException raise:NSInternalInconsistencyException format:@"Please add `GoogleService-Info.plist` to `Supporting Files` and\nURL types > Url Schemes in `Supporting Files/Info.plist` according to https://developers.google.com/identity/sign-in/ios/start-integrating"];
  }
}

- (void)login {
  if ([[GIDSignIn sharedInstance] hasAuthInKeychain]) {
    [[GIDSignIn sharedInstance] signInSilently];
  } else {
    [[GIDSignIn sharedInstance] signIn];
  }
}

- (void)logout {
  [[GIDSignIn sharedInstance] signOut];
  [[GIDSignIn sharedInstance] disconnect];
  [super logout];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
  [self.ref authWithOAuthProvider:kGoogleAuthProvider
                            token:user.authentication.accessToken
              withCompletionBlock:^(NSError *error, FAuthData *authData) {
                if (error) {
                  [self handleError:error];
                }
              }];
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
  if (error) {
    [self.delegate authHelper:self onProviderError:error];
  }
}

@end