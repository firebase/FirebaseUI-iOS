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

#import <UIKit/UIKit.h>

#import <Firebase/Firebase.h>

#import "FirebaseAuthDelegate.h"
#import "FirebaseAuthConstants.h"

/**
 * The base auth provider class that authenticates a user with an identity provider
 * to a Firebase reference. Subclass this to add support for new identity providers.
 */
@interface FirebaseAuthProvider : NSObject

/**
 * The Firebase reference to authenticate against
 */
@property(strong, nonatomic) Firebase *ref;

/**
 * The Firebase authentication data for the currently authenticated user
 */
@property(strong, nonatomic) FAuthData *authData;

/**
 * An enum which represents the chosen authentication provider.
 * See FAuthenticationConstants.h for a full list.
 */
@property(nonatomic) FAuthProvider provider;

/**
 * FirebaseAuthDelegate delegate to handle all login, logout, and error events
 * from both authentication providers and Firebase
 */
@property(weak, nonatomic) id<FirebaseAuthDelegate> delegate;

/**
 * Create an instance of FirebaseAuthProvider, which allows for simple authentication to Firebase
 * via various identity providers (social, email/password, etc.). This method should be called
 * by subclasses
 * @param ref The Firebase reference to use for authentication
 * @param authDelegate A class that implements the FirebaseAuthDelegate protocol
 * @return FirebaseAuthProvider
 */
- (instancetype)initWithRef:(Firebase *)ref authDelegate:(id<FirebaseAuthDelegate>)authDelegate;

/**
 * Log in to the selected authentication provider.
 * Note: you must override this method, as the default implementation raises an exception.
 * @return void
 */
- (void)login;

/**
 * Logout of the currently authenticated provider
 * Note: Always call [super logout] in subclass overrides
 * @return void
 */
- (void)logout;

/**
 * Configure the current authentication provider (for instance, by retrieving keys, testing URL
 * schemes, etc.)
 * Note: you must override this method, as the default implementation raises an exception.
 * @return void
 */
- (void)configureProvider;

- (void)handleError:(NSError *)error;

@end