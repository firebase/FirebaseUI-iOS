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
#import "FirebaseAuthApiKeys.h"
#import "FirebaseTwitterAuthHelper.h"

/**
 * FirebaseLoginViewController is a subclass of UIViewController that provides a
 * set of helper login methods for Firebase authentication providers.
 */
@interface FirebaseLoginViewController
    : UIViewController<FirebaseAuthDelegate, UIActionSheetDelegate>

/**
 * The delegate object that authentication changes are surfaced to, which
 * conforms to the [FirebaseAuthDelegate Protocol](FirebaseAuthDelegate).
 */
@property(weak, nonatomic) id<FirebaseAuthDelegate> delegate;

/**
 * The Firebase database reference which to authenticate against.
 */
@property(strong, nonatomic) Firebase *ref;

/**
 * The set of API Keys associated with each authentication provider.
 */
@property(strong, nonatomic) FirebaseAuthApiKeys *apiKeys;

/**
 * The name of the .plist to read. This is defaulted to "Info".
 */
@property(strong, nonatomic) NSString *pListName;

/**
 * The helper object for Twitter Authentication. This object handles the
 * requests against the Twitter API and uses the response to authenticate
 * against the Firebase database.
 */
@property(strong, nonatomic) FirebaseTwitterAuthHelper *twitterAuthHelper;

/**
 * Authenticates the user against Twitter. This method calls into the
 * twitterAuthHelper property to retrieve a list of Twitter users for the
 * ACAccountStore. If more than one Twitter user is present a UIActionSheet (in
 * < iOS8) or UIAlertViewController (in iOS8+) surfaces with options to select a
 * Twitter user. When the user is selected the authentication process occurs.
 * When authenticated one of the delegate methods in FirebaseAuthDelegate will
 * trigger.
 * @return void
 */
- (void)loginWithTwitter;

- (void)logout;

@end
