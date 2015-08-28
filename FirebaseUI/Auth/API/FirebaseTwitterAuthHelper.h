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
#import "FirebaseAuthDelegate.h"

@interface FirebaseTwitterAuthHelper : NSObject

@property(strong, nonatomic) ACAccountStore *store;
@property(strong, nonatomic) Firebase *ref;
@property(strong, nonatomic) NSString *apiKey;
@property(strong, nonatomic) NSArray *accounts;
@property(weak, nonatomic) id<FirebaseAuthDelegate> delegate;

- (id)initWithFirebaseRef:(Firebase *)ref
                   apiKey:(NSString *)apiKey
                 delegate:(id<FirebaseAuthDelegate>)delegate;

- (void)selectTwitterAccountWithCallback:(void (^)(NSError *error,
                                                   NSArray *accounts))callback;

- (void)authenticateAccount:(ACAccount *)account
               withCallback:
                   (void (^)(NSError *error, FAuthData *authData))callback;

@end

typedef NS_ENUM(NSInteger, AuthHelperError) {
  AuthHelperErrorAccountAccessDenied = -1,
  AuthHelperErrorOAuthTokenRequestDenied = -2
};