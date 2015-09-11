//
//  FirebaseGoogleAuthHelper.h
//  FirebaseUI
//
//  Created by deast on 9/10/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <Firebase/Firebase.h>
#import "FirebaseAuthHelper.h"

@interface FirebaseGoogleAuthHelper : NSObject<FirebaseAuthHelper>

/**
 * The Firebase database reference which to authenticate against.
 */
@property(strong, nonatomic) Firebase *ref;

/**
 * The delegate object that authentication changes are surfaced to, which
 * conforms to the [FirebaseAuthDelegate Protocol](FirebaseAuthDelegate).
 */
@property(weak, nonatomic) id<FirebaseAuthDelegate> delegate;

- (instancetype)initWithRef:(Firebase *)ref
                   delegate:(id<FirebaseAuthHelper>)delegate;

- (void)login;

- (void)logout;

@end
