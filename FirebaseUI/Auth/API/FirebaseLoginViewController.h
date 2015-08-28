//
//  Header.h
//  FirebaseUI
//
//  Created by deast on 8/24/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import "FirebaseAuthDelegate.h"
#import "FirebaseAuthApiKeys.h"
#import "FirebaseTwitterAuthHelper.h"

typedef NS_ENUM(NSInteger, FirebaseAuthProvider) {
  FirebaseAuthProviderGoogle,
  FirebaseAuthProviderTwitter,
  FirebaseAuthProviderFacebook,
  FirebaseAuthProviderPassword,
  FirebaseAuthProviderGithub,
  FirebaseAuthProviderAnonymous
};

@interface FirebaseLoginViewController
    : UIViewController<FirebaseAuthDelegate, UIActionSheetDelegate>

@property(weak, nonatomic) id<FirebaseAuthDelegate> delegate;
@property(strong, nonatomic) Firebase *ref;
@property(strong, nonatomic) FirebaseAuthApiKeys *apiKeys;
@property(strong, nonatomic) NSString *pListName;
@property(strong, nonatomic) FirebaseTwitterAuthHelper *twitterAuthHelper;

- (void)loginWithTwitter;

@end
