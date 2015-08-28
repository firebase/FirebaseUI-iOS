//
//  FirebaseAuthProvider.m
//  FirebaseUI
//
//  Created by deast on 8/28/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FirebaseAuthProvider) {
  FirebaseAuthProviderGoogle,
  FirebaseAuthProviderTwitter,
  FirebaseAuthProviderFacebook,
  FirebaseAuthProviderPassword,
  FirebaseAuthProviderGithub,
  FirebaseAuthProviderAnonymous
};