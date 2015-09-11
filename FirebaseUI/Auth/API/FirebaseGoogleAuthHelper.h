//
//  FirebaseGoogleAuthHelper.h
//  FirebaseUI
//
//  Created by deast on 9/10/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <Google/SignIn.h>
#import <Firebase/Firebase.h>

@interface FirebaseGoogleAuthHelper : NSObject

/**
 * The Firebase database reference which to authenticate against.
 */
@property(strong, nonatomic) Firebase *ref;

- (instancetype)initWithFirebaseRef:(Firebase *)ref
            authStateChangeCallback:(void (^)(FAuthData *authData))callback;

- (void)loginWithCallback:(void (^)(NSError *error,
                                    FAuthData *authData))callback;

@end
