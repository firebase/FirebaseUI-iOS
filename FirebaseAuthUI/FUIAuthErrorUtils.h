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

#import "FUIAuthErrors.h"

NS_ASSUME_NONNULL_BEGIN

/** @class FUIAuthErrorUtils
    @brief Utility class used to construct @c NSError instances.
 */
@interface FUIAuthErrorUtils : NSObject

/** @fn errorWithCode:
    @brief Creates an error with the specified code.
    @param code The error code.
    @param userInfo The dictionary containing the error description if available.
    @return An @c NSError with the correct code and corresponding description if available.
 */
+ (NSError *)errorWithCode:(FUIAuthErrorCode)code userInfo:(nullable NSDictionary *)userInfo;

/** @fn userCancelledSignInError
    @brief Constructs an @c NSError with the @c FUIAuthErrorCodeUserCancelledSignIn code.
 */
+ (NSError *)userCancelledSignInError;

/** @fn mergeConflictErrorWithUserInfo:underlyingError:
    @brief Constructs an @c NSError with the @c FUIAuthErrorCodeMergeConflict code.
    @param userInfo The userInfo dictionary to add to the NSError object.
    @param underlyingError The error that was raised by FirebaseAuth while merging accounts.
    @return The merge conflict error.
 */
+ (NSError *)mergeConflictErrorWithUserInfo:(NSDictionary *)userInfo
                            underlyingError:(nullable NSError *)underlyingError;

/** @fn providerErrorWithUnderlyingError:providerID:
    @brief Constructs an @c NSError with the @c FUIAuthErrorCodeProviderError code and a populated
        @c NSUnderlyingErrorKey and @c FUIAuthErrorUserInfoProviderIDKey in the
        @c NSError.userInfo dictionary.
    @param underlyingError The value of the @c NSUnderlyingErrorKey.
    @param providerID The value of the @c FUIAuthErrorUserInfoProviderIDKey.
    @remarks This error is used when an error from the identity provider cannot be immediately
        handled, and should be forwarded to the client.
 */
+ (NSError *)providerErrorWithUnderlyingError:(NSError *)underlyingError
                                   providerID:(NSString *)providerID;

@end

NS_ASSUME_NONNULL_END
