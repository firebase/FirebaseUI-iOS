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

#import <Foundation/Foundation.h>
#import "FUICountryCodes.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const FUIPhoneNumberValidationErrorDomain;

typedef NS_ENUM(NSInteger, FUIPhoneNumberValidationError) {
    FUIPhoneNumberValidationErrorMissingPlus = 0,
    FUIPhoneNumberValidationErrorMissingDialCode = 1,
    FUIPhoneNumberValidationErrorMissingNumber = 2,
};

/** Encapsulates a phone number with the raw and the normalized representations */
@interface FUIPhoneNumber : NSObject

@property (nonatomic, readonly) FUICountryCodeInfo *countryCode;
@property (nonatomic, copy, readonly) NSString *rawPhoneNumber;
@property (nonatomic, copy, readonly) NSString *normalizedPhoneNumber;

/** @fn initWithNormalizedPhoneNumber:
    @brief Attempts to parse the given phone number into a raw phone number and country code.
        Parse behavior:
          If given phone number starts with a '+' character, then look for the country code matching
          the prefix of the number.
        Otherwise use the normalized number as the raw number, and find the country code using the
            device locale.
    @param normalizedPhoneNumber   (required) A phone number string that will be parsed into
        a raw phone number and country code.
    @return object or nil if any of the required parameters is nil.
*/
- (instancetype)initWithNormalizedPhoneNumber:(NSString *)normalizedPhoneNumber;

/** @fn initWithRawPhoneNumber:countryCode:
    @param rawPhoneNumber           (required) The raw phone number without country code
    @param countryCode              (required) The country code information
    @return object or nil if any of the required parameters is nil.
*/
- (instancetype)initWithRawPhoneNumber:(NSString *)rawPhoneNumber
                           countryCode:(FUICountryCodeInfo *)countryCode;

/** @fn initWithNormalizedPhoneNumber:rawPhoneNumber:countryCode:
    @param normalizedPhoneNumber    (optional) The phone number returned from the endpoint;
        if null or empty it will be computed ('+' + rawCountryCode + rawPhoneNumber)
    @param rawPhoneNumber           (required) The raw phone number without country code
    @param countryCode              (required) The country code information
    @return object or nil if any of the required parameters is nil.
*/
- (instancetype)initWithNormalizedPhoneNumber:(NSString *)normalizedPhoneNumber
                               rawPhoneNumber:(NSString *)rawPhoneNumber
                                  countryCode:(FUICountryCodeInfo *)countryCode;

- (instancetype)init NS_UNAVAILABLE;

/** @fn validate:
    @brief Checks if current phone number has valid international format.
    @param errorRef The error which occurred, if any.
    @return True if phone number format is valid.
*/
- (BOOL)validate:(NSError *__autoreleasing _Nullable *_Nullable)errorRef;
@end

NS_ASSUME_NONNULL_END
