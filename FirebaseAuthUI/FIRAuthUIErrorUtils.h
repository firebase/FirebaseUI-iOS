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

#import "FIRAuthUIErrors.h"

NS_ASSUME_NONNULL_BEGIN

/** @class FIRAuthUIErrorUtils
    @brief Utility class used to construct @c NSError instances.
 */
@interface FIRAuthUIErrorUtils : NSObject

/** @fn errorWithCode:
    @brief Creates an error with the specified code.
    @param code The error code.
    @param userInfo The dictionary containing the error description if available.
    @return An @c NSError with the correct code and corresponding description if available.
 */
+ (NSError *)errorWithCode:(FIRAuthUIErrorCode)code userInfo:(nullable NSDictionary *)userInfo;

/** @fn userCancelledSignIn
    @brief Constructs an @c NSError with the @c FIRAuthUIErrorCodeUserCancelledSignIn code.
 */
+ (NSError *)userCancelledSignInError;

/** @fn providerErrorWithUnderlyingError:providerID:
    @brief Constructs an @c NSError with the @c FIRAuthUIErrorCodeProviderError code and a populated
        @c NSUnderlyingErrorKey and @c FIRAuthUIErrorUserInfoProviderIDKey in the
        @c NSError.userInfo dictionary.
    @param underlyingError The value of the @c NSUnderlyingErrorKey.
    @param providerID The value of the @c FIRAuthUIErrorUserInfoProviderIDKey.
    @remarks This error is used when an error from the identity provider cannot be immediately
        handled, and should be forwarded to the client.
 */
+ (NSError *)providerErrorWithUnderlyingError:(NSError *)underlyingError
                                   providerID:(NSString *)providerID;

@end

NS_ASSUME_NONNULL_END
