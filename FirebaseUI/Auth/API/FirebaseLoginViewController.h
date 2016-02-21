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
#import <QuartzCore/QuartzCore.h>

#import <Firebase/Firebase.h>

// Shared auth
#import "FirebaseAuthDelegate.h"
#import "FirebaseLoginButton.h"
#import "FirebaseAuthProvider.h"

// Pull in Twitter
#if FIREBASEUI_ENABLE_TWITTER_AUTH
#import "FirebaseTwitterAuthProvider.h"
#endif

// Pull in Facebook
#if FIREBASEUI_ENABLE_FACEBOOK_AUTH
#import "FirebaseFacebookAuthProvider.h"
#endif

// Pull in Google
#if FIREBASEUI_ENABLE_GOOGLE_AUTH
#import "FirebaseGoogleAuthProvider.h"
#endif

// Google local build issues
#if FIREBASEUI_ENABLE_GOOGLE_AUTH
#if LOCAL_BUILD
#import <GoogleSignIn/GoogleSignIn.h>
#else
#import <Google/SignIn.h>
#endif
#endif

// Pull in Password
#if FIREBASEUI_ENABLE_PASSWORD_AUTH
#import "FirebasePasswordAuthProvider.h"
#endif

/**
 * FirebaseLoginViewController is a subclass of UIViewController that provides a
 * set of helper methods for Firebase authentication providers. FirebaseLoginViewController
 * also provides a premade UI which handles login and logout with arbitrary providers, as well as
 * error handling.
 * This also serves as a template for developers interested in developing custom login UI.
 */
#if FIREBASEUI_ENABLE_TWITTER_AUTH && FIREBASEUI_ENABLE_GOOGLE_AUTH
@interface FirebaseLoginViewController
    : UIViewController<FirebaseAuthDelegate, TwitterAuthDelegate, GIDSignInUIDelegate>
#elif FIREBASEUI_ENABLE_TWITTER_AUTH
@interface FirebaseLoginViewController
: UIViewController<FirebaseAuthDelegate, TwitterAuthDelegate>
#elif FIREBASEUI_ENABLE_GOOGLE_AUTH
@interface FirebaseLoginViewController
: UIViewController<FirebaseAuthDelegate, GIDSignInUIDelegate>
#else
@interface FirebaseLoginViewController: UIViewController<FirebaseAuthDelegate>
#endif


/**
 * Container view for login activity which wraps the header text and cancel button.
 */
@property(weak, nonatomic) IBOutlet UIView *headerView;

/**
 * Header text, defaults to "Please Sign In"
 */
@property(weak, nonatomic) IBOutlet UILabel *headerText;

/**
 * Cancel button, defaults to Grey 500 material cancel image.
 */
@property(weak, nonatomic) IBOutlet UIButton *cancelButton;

/**
 * Container view for email and password textfields as well as the email/password login button.
 */
@property(weak, nonatomic) IBOutlet UIView *emailPasswordView;

/**
 * Email text field.
 */
@property(weak, nonatomic) IBOutlet UITextField *emailTextField;

/**
 * Password text field.
 */
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;

/**
 *Container for ------or------ line.
 */
@property(weak, nonatomic) IBOutlet UIView *separatorView;

/**
 * Container view for social provider login button.
 */
@property(weak, nonatomic) IBOutlet UIView *socialView;

/**
 * Container view for full login UI.
 */
@property(weak, nonatomic) IBOutlet UIView *loginView;

/**
 * Height constraint for social view.
 */
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *socialHeightConstraint;

/**
 * Height constraint for login view view.
 */
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *totalHeightConstraint;

/**
 * Dismissal callback on success or failure.
 */
@property(nonatomic, copy) void (^dismissCallback)(FAuthData *user, NSError *error);

/**
 * The Firebase database reference which to authenticate against.
 */
@property(strong, nonatomic) Firebase *ref;

/**
 * The provider object for Twitter Authentication. This object handles the
 * requests against the Twitter API and uses the response to authenticate
 * against the Firebase database.
 */
#if FIREBASEUI_ENABLE_TWITTER_AUTH
@property(strong, nonatomic) FirebaseTwitterAuthProvider *twitterAuthProvider;
#else
@property(strong, nonatomic) FirebaseAuthProvider *twitterAuthProvider;
#endif

/**
 * The provider object for Facebook Authentication. This object handles the
 * requests against the Facebook SDK and uses the response to authenticate
 * against the Firebase database.
 */
#if FIREBASEUI_ENABLE_FACEBOOK_AUTH
@property(strong, nonatomic) FirebaseFacebookAuthProvider *facebookAuthProvider;
#else
@property(strong, nonatomic) FirebaseAuthProvider *facebookAuthProvider;
#endif


/**
 * The provider object for Google Authentication. This object handles the
 * requests against the Google SDK and uses the response to authenticate
 * against the Firebase database.
 */
#if FIREBASEUI_ENABLE_GOOGLE_AUTH
@property(strong, nonatomic) FirebaseGoogleAuthProvider *googleAuthProvider;
#else
@property(strong, nonatomic) FirebaseAuthProvider *googleAuthProvider;
#endif

/**
 * The provider object for Email/Password Authentication. This object handles the
 * requests to the Firebase user authentication system to authenticate users to
 * the Firebase database.
 */
#if FIREBASEUI_ENABLE_PASSWORD_AUTH
@property(strong, nonatomic) FirebasePasswordAuthProvider *passwordAuthProvider;
#else
@property(strong, nonatomic) FirebaseAuthProvider *passwordAuthProvider;
#endif

/**
 * Create an instance of FirebaseLoginViewController, which allows for easy authentication to
 * Firebase
 * via a number of identity providers such as Email/Password, Google, Facebook, and Twitter.
 * @param ref The Firebase reference to use for authentication
 * @return FirebaseLoginViewController
 */
- (instancetype)initWithRef:(Firebase *)ref;

/**
 * Enables a given identity provider and allows for login and logout actions against it.
 * @param provider An enum representing the desired identity provider to log in with
 * @return FirebaseLoginViewController
 */
- (instancetype)enableProvider:(FAuthProvider)provider;

/**
 * Callback that fires when after the controller is dismissed (either on success or on failure).
 * If successful, the user field will be populated; if an error occurred the error field will be
 * populated.
 * @param callback A block that returns a user on success or an error on failure.
 * @return void
 */
- (void)didDismissWithBlock:(void (^)(FAuthData *user, NSError *error))callback;

/**
 * Logs the currently authenticated user out of both Firebase and the currently logged in identity
 * provider (if any).
 * @return void
 */
- (void)logout;

/**
 * Returns the currently authenticated user or nil if no user is authenticated.
 * @return FAuthData
 */
- (FAuthData *)currentUser;

@end
