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

#if LOCAL_BUILD
#import <GoogleSignIn/GoogleSignIn.h>
#else
#import <Google/SignIn.h>
#endif

#import "FirebaseAuthProvider.h"

/**
 * An authentication provider class that authenticates a user with Google
 * and uses the credentials to authenticate a Firebase reference
 */
@interface FirebaseGoogleAuthProvider : FirebaseAuthProvider<GIDSignInDelegate, GIDSignInUIDelegate>

/**
 * Create an instance of FirebaseGoogleAuthProvider, which allows for simple authentication to
 * Firebase via Gooogle
 * @param ref The Firebase reference to use for authentication
 * @param authDelegate A class that implements the FirebaseAuthDelegate protocol
 * @param uiDelegate A UIViewController subclass that implements the GIDSignInUIDelegate protocol
 * @return FirebaseGoogleAuthProvider
 */
- (instancetype)initWithRef:(Firebase *)ref
               authDelegate:(id<FirebaseAuthDelegate>)authDelegate
                 uiDelegate:(UIViewController<GIDSignInUIDelegate> *)uiDelegate;

@end
