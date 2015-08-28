//
//  FirebaseAuthDelegate.h
//  FirebaseUI
//
//  Created by deast on 8/25/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import <Firebase/Firebase.h>

@protocol FirebaseAuthDelegate<NSObject>

- (void)onLogin:(FAuthData *)authData;

@optional
- (void)onError:(NSError *)error;

@optional
- (void)onAuthStageChange:(FAuthData *)authData;

@end
