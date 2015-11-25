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

#import <Firebase/Firebase.h>

/**
 * A protocol that defines the contract of authentication state changes from a
 * Firebase database reference.
 */
@protocol FirebaseAuthDelegate<NSObject>

@required
/**
 * Method that fires when a user is logged in via any provider. Information about the provider comes
 * through the authProvider.
 * @param provider An instance of FirebaseAuthProvider which contains information about the provider
 * @param authData A class that implements the FirebaseAuthDelegate protocol
 * @return void
 */
- (void)authProvider:(id)provider onLogin:(FAuthData *)authData;

/**
 * Method that fires when a user is logged out of the current authentication provider.
 * @return void
 */
- (void)onLogout;

@optional
/**
 * Method that fires when authentication fails due to an error on the provider side.
 * This could include Firebase authentication (provider incorrectly set up in the Firebase
 * Dashboard)
 * or issues with the provider itself (provider is down, incorrectly provisioned, etc.).
 * @param provider An instance of FirebaseAuthProvider which contains information about the provider
 * @param error
 * @return void
 */
- (void)authProvider:(id)provider onProviderError:(NSError *)error;

/**
 * Method that fires when authentication fails due to an error on the user side.
 * This could include incorrect email/password, or a user canceling an authentication request
 * with an identity provider.
 * @param provider An instance of FirebaseAuthProvider which contains information about the provider
 * @param error
 * @return void
 */
- (void)authProvider:(id)provider onUserError:(NSError *)error;

@end
