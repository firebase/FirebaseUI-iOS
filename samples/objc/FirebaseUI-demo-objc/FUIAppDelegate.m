//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "FUIAppDelegate.h"

@import Firebase;
@import FirebaseUI;
#import <GTMSessionFetcher/GTMSessionFetcherLogging.h>
#import <TwitterKit/TWTRTwitter.h>

// TODO: Update with Twitter key and secret
NSString *const kTwitterConsumerKey = @"";
NSString *const kTwitterConsumerSecret = @"";

@implementation FUIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  if (kTwitterConsumerKey.length && kTwitterConsumerSecret.length) {
    [[TWTRTwitter sharedInstance] startWithConsumerKey:kTwitterConsumerKey
                                        consumerSecret:kTwitterConsumerSecret];
  }

  [FIRApp configure];
  [GTMSessionFetcher setLoggingEnabled:YES];
  return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
  NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
  return [self handleOpenUrl:url sourceApplication:sourceApplication];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
  return [self handleOpenUrl:url sourceApplication:sourceApplication];
}

- (BOOL)handleOpenUrl:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication {
  if ([FUIAuth.defaultAuthUI handleOpenURL:url sourceApplication:sourceApplication]) {
    return YES;
  }
  return NO;
}

@end
