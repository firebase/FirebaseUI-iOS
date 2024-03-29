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
#import <OCMock/OCMock.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface FUIFacebookAuthTest ()
@property(nonatomic) FBSDKLoginManagerLoginResult *result;
@property(nonatomic) NSError *error;
@end

@implementation FUIFacebookAuthTest

- (FBSDKLoginManager *)createLoginManager {
  id mock = OCMClassMock([FBSDKLoginManager class]);
  OCMStub(
          [mock logInWithPermissions:[OCMArg any]
                  fromViewController:[OCMArg any]
                             handler:[OCMArg any]]
          ).andDo(^(NSInvocation *invocation) {
            void (^completion)(FBSDKLoginManagerLoginResult *, NSError *);
            [invocation getArgument:&completion atIndex:4];
            completion(self.result, self.error);
          });
  return mock;
}

- (void)configureLoginManager:(FBSDKLoginManagerLoginResult *)result withError:(NSError *)error {
  self.result = result;
  self.error = error;
}

@end
