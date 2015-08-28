//
//  FirebaseAuthApiKeys.h
//  FirebaseUI
//
//  Created by deast on 8/25/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FirebaseAuthApiKeys : NSObject

@property(strong, nonatomic) NSString *twitterApiKey;
@property(strong, nonatomic) NSString *facebookApiKey;
@property(strong, nonatomic) NSString *googleApiKey;
@property(strong, nonatomic) NSString *githubApiKey;

@end