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
#import <FirebaseUI/FirebaseUI.h>
#import <GTMSessionFetcher/GTMSessionFetcherLogging.h>

@implementation FUIAppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [FIRApp configure];
  [GTMSessionFetcher setLoggingEnabled:YES];
  return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options {
  NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
  return [self handleOpenUrl:url sourceApplication:sourceApplication];
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(nonnull NSUserActivity *)userActivity
 restorationHandler:
#if defined(__IPHONE_12_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_0)
  (nonnull void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
#else
  (nonnull void (^)(NSArray *_Nullable))restorationHandler {
#endif  // __IPHONE_12_0
    BOOL handled = [[FIRDynamicLinks dynamicLinks]
                    handleUniversalLink:userActivity.webpageURL
                    completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                 NSError * _Nullable error) {
                      if (error) {
                        NSLog(@"%@", error.description);
                      } else {
                        [self handleOpenUrl:dynamicLink.url sourceApplication:nil];
                      }
                    }];
    return handled;
  }

- (BOOL)handleOpenUrl:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication {
  if ([FUIAuth.defaultAuthUI handleOpenURL:url sourceApplication:sourceApplication]) {
    return YES;
  }
  return NO;
}

@end
