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

NS_ASSUME_NONNULL_BEGIN

@interface FUICountryCodeInfo : NSObject

@property (nonatomic, copy) NSString *countryName;
@property (nonatomic, copy) NSString *localizedCountryName;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *dialCode;
@property (nonatomic, copy) NSNumber *level;

- (NSString *)countryFlagEmoji;

@end

@interface FUICountryCodes : NSObject

/** @fn count:
    @brief Return the number of available country codes.
*/
- (NSUInteger)count;

/** @fn countryCodeInfoAtIndex:
    @brief Get the @c FUICountryCodeInfo object with provided index.
    @param index The index number of the object.
*/
- (FUICountryCodeInfo *)countryCodeInfoAtIndex:(NSInteger)index;

/** @fn countryCodeInfoForPhoneNumber:
    @brief Get the @c FUICountryCodeInfo object based on the provided phone number.
    @param phoneNumber The phone number in string format.
*/
- (FUICountryCodeInfo *)countryCodeInfoForPhoneNumber:(NSString *)phoneNumber;

/** @fn countryCodeInfoForCode:
    @brief Get the @c FUICountryCodeInfo object of the selected country code.
    @param countryCode Country codes are in NSString format, and ISO (alpha-2) formatted.
*/
- (nullable FUICountryCodeInfo *)countryCodeInfoForCode:(NSString *)countryCode;

/** @fn defaultCountryCodeInfo
    @brief Get the default country code info
    @detail The default country is retrieved based on the following logic:
            1. The country code info of user's carrier provider if available.
            2. The country code info of user's device locale, if available.
            3. A hard coded coutry code info (US), if available.
            4. The first available country code info in the instance.
*/
- (FUICountryCodeInfo *)defaultCountryCodeInfo;

/** @fn blacklistCountries:
    @brief Remove the set of countries from available country codes.
    @param countries A set of blacklisted country codes. Country codes are in NSString format, and
           are either ISO (alpha-2) or E164 formatted.
*/
- (void)blacklistCountries:(NSSet<NSString *> *)countries;

/** @fn blacklistCountries:
    @brief Filter the available country codes, leaving only the set of whitelisted countries.
    @param countries A set of whitelisted country codes. Country codes are in NSString format, and
           are either ISO (alpha-2) or E164 formatted.
*/
- (void)whitelistCountries:(NSSet<NSString *> *)countries;

/** @fn searchCountriesByName:
    @brief Get a filtered instance based on provided country name query.
    @param nameQuery The search query.
*/
- (instancetype)searchCountriesByName:(NSString *)nameQuery;

@end

NS_ASSUME_NONNULL_END
