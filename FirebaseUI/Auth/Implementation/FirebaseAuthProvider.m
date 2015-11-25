//
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

#import <Foundation/Foundation.h>

#import "FirebaseAuthProvider.h"

@implementation FirebaseAuthProvider {
  FirebaseHandle _authHandle;
}

- (instancetype)initWithRef:(Firebase *)ref authDelegate:(id<FirebaseAuthDelegate>)authDelegate {
  self = [super init];
  if (self) {
    self.ref = ref;
    self.delegate = authDelegate;

    // Set up the auth handler to be a singleton across all auth providers
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _authHandle = [self.ref observeAuthEventWithBlock:^(FAuthData *authData) {
        if (authData) {
          self.authData = authData;
          [self.delegate authProvider:self onLogin:authData];
        } else {
          self.authData = nil;
          [self.delegate onLogout];
        }
      }];
    });
  }
  return self;
}

- (void)login {
  [NSException raise:NSInternalInconsistencyException
              format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)logout {
  [self.ref unauth];
}

- (void)configureProvider {
  [NSException raise:NSInternalInconsistencyException
              format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)handleError:(NSError *)error {
  switch (error.code) {
    case FAuthenticationErrorDeniedByUser:
      [self.delegate authProvider:self onUserError:error];
      break;

    case FAuthenticationErrorEmailTaken:
      [self.delegate authProvider:self onUserError:error];
      break;

    case FAuthenticationErrorInvalidArguments:
      [self.delegate authProvider:self onProviderError:error];
      break;

    case FAuthenticationErrorInvalidConfiguration:
      [self.delegate authProvider:self onProviderError:error];
      break;

    case FAuthenticationErrorInvalidCredentials:
      [self.delegate authProvider:self onUserError:error];
      break;

    case FAuthenticationErrorInvalidEmail:
      [self.delegate authProvider:self onUserError:error];
      break;

    case FAuthenticationErrorInvalidOrigin:
      [self.delegate authProvider:self onProviderError:error];
      break;

    case FAuthenticationErrorInvalidPassword:
      [self.delegate authProvider:self onUserError:error];
      break;

    case FAuthenticationErrorInvalidProvider:
      [self.delegate authProvider:self onProviderError:error];
      break;

    case FAuthenticationErrorInvalidToken:
      [self.delegate authProvider:self onProviderError:error];
      break;

    case FAuthenticationErrorLimitsExceeded:
      [self.delegate authProvider:self onProviderError:error];
      break;

    case FAuthenticationErrorNetworkError:
      [self.delegate authProvider:self onUserError:error];
      break;

    case FAuthenticationErrorPreempted:
      [self.delegate authProvider:self onProviderError:error];
      break;

    case FAuthenticationErrorProviderDisabled:
      [self.delegate authProvider:self onProviderError:error];
      break;

    case FAuthenticationErrorProviderError:
      [self.delegate authProvider:self onProviderError:error];
      break;

    case FAuthenticationErrorUnknown:
      [self.delegate authProvider:self onProviderError:error];
      break;

    case FAuthenticationErrorUserDoesNotExist:
      [self.delegate authProvider:self onUserError:error];
      break;

    default:
      [self.delegate authProvider:self onProviderError:error];
      break;
  }
}

@end
