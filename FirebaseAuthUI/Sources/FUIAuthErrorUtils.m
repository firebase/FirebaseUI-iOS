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

#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthErrorUtils.h"

@implementation FUIAuthErrorUtils

+ (NSError *)errorWithCode:(FUIAuthErrorCode)code userInfo:(NSDictionary *)userInfo {
  return [NSError errorWithDomain:FUIAuthErrorDomain code:code userInfo:userInfo];
}

+ (NSError *)userCancelledSignInError {
  return [self errorWithCode:FUIAuthErrorCodeUserCancelledSignIn userInfo:nil];
}

+ (NSError *)mergeConflictErrorWithUserInfo:(NSDictionary *)userInfo
                            underlyingError:(NSError *)underlyingError {
  NSMutableDictionary *errorInfo = [userInfo mutableCopy];
  if (underlyingError != nil) {
    errorInfo[NSUnderlyingErrorKey] = underlyingError;
  }
  errorInfo[NSLocalizedDescriptionKey] = @"Unable to merge accounts. Check the userInfo dictionary"
      @" for the auth credential of the logged-in account.";
  return [self errorWithCode:FUIAuthErrorCodeMergeConflict userInfo:[errorInfo copy]];
}

+ (NSError *)providerErrorWithUnderlyingError:(NSError *)underlyingError
                                   providerID:(NSString *)providerID {
  return [self errorWithCode:FUIAuthErrorCodeProviderError
                    userInfo:@{
    NSUnderlyingErrorKey : underlyingError,
    FUIAuthErrorUserInfoProviderIDKey : providerID
  }];
}

@end
