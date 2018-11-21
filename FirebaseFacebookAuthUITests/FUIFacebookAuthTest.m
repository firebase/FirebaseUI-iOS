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
#import "FUIFacebookAuthTest.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface FBSDKLoginManagerTest : FBSDKLoginManager
@property(nonatomic) FBSDKLoginManagerLoginResult *result;
@property(nonatomic) NSError *error;
@end

@implementation FBSDKLoginManagerTest

- (void)logInWithReadPermissions:(NSArray *)permissions
              fromViewController:(UIViewController *)fromViewController
                         handler:(FBSDKLoginManagerRequestTokenHandler)handler {
  handler(self.result, self.error);
}
@end


@implementation FUIFacebookAuthTest

- (FBSDKLoginManager *)createLoginManager {
  return [[FBSDKLoginManagerTest alloc] init];
}

- (void)configureLoginManager:(FBSDKLoginManagerLoginResult *)result withError:(NSError *)error {
  ((FBSDKLoginManagerTest *)_loginManager).result = result;
  ((FBSDKLoginManagerTest *)_loginManager).error = error;
}

@end
