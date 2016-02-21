// clang-format off

/*
 * Firebase UI Bindings iOS Library
 *
 * Copyright © 2015 Firebase - All Rights Reserved
 * https://www.firebase.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// clang-format on

#import "FirebaseGoogleAuthProvider.h"

@implementation FirebaseGoogleAuthProvider

- (instancetype)initWithRef:(Firebase *)ref
               authDelegate:(id<FirebaseAuthDelegate>)authDelegate
                 uiDelegate:(UIViewController<GIDSignInUIDelegate> *)uiDelegate {
  self = [super initWithRef:ref authDelegate:authDelegate];
  if (self) {
    self.provider = FAuthProviderGoogle;
    [self configureProvider];
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = uiDelegate;
  }
  return self;
}

- (void)configureProvider {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
  NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];
  NSString *reversedClientId = [plist objectForKey:@"REVERSED_CLIENT_ID"];
  BOOL clientIdExists = [plist objectForKey:@"CLIENT_ID"] != nil;
  BOOL reversedClientIdExists = reversedClientId != nil;

  if (!(clientIdExists && reversedClientIdExists)) {
    [NSException raise:NSInternalInconsistencyException
                format:@"Please add `GoogleService-Info.plist` to `Supporting Files` and\nURL "
                @"types > Url Schemes in `Supporting Files/Info.plist` according to "
                @"https://developers.google.com/identity/sign-in/ios/start-integrating"];
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

- (void)signIn:(GIDSignIn *)signIn
    didSignInForUser:(GIDGoogleUser *)user
           withError:(NSError *)error {
  [self.ref authWithOAuthProvider:@"google"
                            token:user.authentication.accessToken
              withCompletionBlock:^(NSError *error, FAuthData *authData) {
                if (error) {
                  [self handleError:error];
                }
              }];
}

- (void)signIn:(GIDSignIn *)signIn
    didDisconnectWithUser:(GIDGoogleUser *)user
                withError:(NSError *)error {
  if (error) {
    [self.delegate authProvider:self onProviderError:error];
  }
}

@end