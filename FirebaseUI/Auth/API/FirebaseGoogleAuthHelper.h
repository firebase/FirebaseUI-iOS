//
//  FirebaseGoogleAuthHelper.h
//  FirebaseUI
//
//  Created by deast on 9/10/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <GoogleSignIn/GoogleSignIn.h>
#import <Firebase/Firebase.h>
#import "FirebaseAuthHelper.h"

@interface FirebaseGoogleAuthHelper
    : NSObject<FirebaseAuthHelper, GIDSignInDelegate, GIDSignInUIDelegate>

/**
 * The Firebase database reference which to authenticate against.
 */
@property(strong, nonatomic) Firebase *ref;

/**
 * The delegate object that authentication changes are surfaced to, which
 * conforms to the [FirebaseAuthDelegate Protocol](FirebaseAuthDelegate).
 */
@property(weak, nonatomic) UIViewController<FirebaseAuthDelegate> *delegate;

- (instancetype)initWithRef:(Firebase *)ref
                   delegate:(id<FirebaseAuthHelper>)delegate;

- (instancetype)initWithRef:(Firebase *)ref
                   delegate:
                       (UIViewController<FirebaseAuthDelegate> *)authDelegate
             signInDelegate:(id<GIDSignInDelegate>)signInDelegate
                 uiDelegate:(id<GIDSignInUIDelegate>)uiDelegate;

- (void)login;

- (void)logout;

@end
