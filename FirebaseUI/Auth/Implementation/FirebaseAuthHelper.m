//
//  FirebaseAuthHelper.m
//  FirebaseUI
//
//  Created by Mike Mcdonald on 11/12/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FirebaseAuthHelper.h"

@implementation FirebaseAuthHelper {
  FirebaseHandle _authHandle;
}

- (instancetype) initWithRef:(Firebase *)ref authDelegate: (id<FirebaseAuthDelegate>) authDelegate {
  self = [super init];
  if (self) {
    self.ref = ref;
    self.delegate = authDelegate;
    
    // Set up the auth handler to be a singleton across all auth helpers
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _authHandle = [self.ref observeAuthEventWithBlock:^(FAuthData *authData) {
        if (authData) {
          self.authData = authData;
          [self.delegate authHelper:self onLogin:authData];
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
  [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)logout {
  [self.ref unauth];
}

- (void)configureProvider {
  [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)handleError:(NSError *)error {
  switch (error.code) {
    case FAuthenticationErrorDeniedByUser:
      [self.delegate authHelper:self onUserError:error];
      break;
      
    case FAuthenticationErrorEmailTaken:
      [self.delegate authHelper:self onUserError:error];
      break;
      
    case FAuthenticationErrorInvalidArguments:
      [self.delegate authHelper:self onProviderError:error];
      break;
      
    case FAuthenticationErrorInvalidConfiguration:
      [self.delegate authHelper:self onProviderError:error];
      break;
      
    case FAuthenticationErrorInvalidCredentials:
      [self.delegate authHelper:self onUserError:error];
      break;
      
    case FAuthenticationErrorInvalidEmail:
      [self.delegate authHelper:self onUserError:error];
      break;
      
    case FAuthenticationErrorInvalidOrigin:
      [self.delegate authHelper:self onProviderError:error];
      break;
      
    case FAuthenticationErrorInvalidPassword:
      [self.delegate authHelper:self onUserError:error];
      break;
      
    case FAuthenticationErrorInvalidProvider:
      [self.delegate authHelper:self onProviderError:error];
      break;
      
    case FAuthenticationErrorInvalidToken:
      [self.delegate authHelper:self onProviderError:error];
      break;
      
    case FAuthenticationErrorLimitsExceeded:
      [self.delegate authHelper:self onProviderError:error];
      break;
      
    case FAuthenticationErrorNetworkError:
      [self.delegate authHelper:self onUserError:error];
      break;
      
    case FAuthenticationErrorPreempted:
      [self.delegate authHelper:self onProviderError:error];
      break;
      
    case FAuthenticationErrorProviderDisabled:
      [self.delegate authHelper:self onProviderError:error];
      break;
      
    case FAuthenticationErrorProviderError:
      [self.delegate authHelper:self onProviderError:error];
      break;
      
    case FAuthenticationErrorUnknown:
      [self.delegate authHelper:self onProviderError:error];
      break;
      
    case FAuthenticationErrorUserDoesNotExist:
      [self.delegate authHelper:self onUserError:error];
      break;
      
    default:
      [self.delegate authHelper:self onProviderError:error];
      break;
  }
}

@end
