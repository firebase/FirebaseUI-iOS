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

#import "FUIPhoneNumber.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const FUIPhoneNumberValidationErrorDomain = @"FUIPhoneNumberValidationErrorDomain";

@implementation FUIPhoneNumber

- (instancetype)initWithNormalizedPhoneNumber:(NSString *)normalizedPhoneNumber {
  if (!normalizedPhoneNumber) {
    return nil;
  }
  NSString *rawPhoneNumber;
  FUICountryCodes *codes = [[FUICountryCodes alloc] init];
  FUICountryCodeInfo *countryCode = [codes countryCodeInfoForPhoneNumber:normalizedPhoneNumber];

  if (countryCode) {
    // Add 1 for the '+' character
    NSInteger countryCodeLength = countryCode.dialCode.length + 1;
    if (normalizedPhoneNumber.length >= countryCodeLength) {
      rawPhoneNumber = [normalizedPhoneNumber substringFromIndex:countryCodeLength];
    }
  }
  if (!rawPhoneNumber) {
    rawPhoneNumber = normalizedPhoneNumber;
    countryCode = [codes countryCodeInfoFromDeviceLocale];
  }
  return [self initWithRawPhoneNumber:rawPhoneNumber countryCode:countryCode];
}

- (instancetype)initWithNormalizedPhoneNumber:(NSString *)normalizedPhoneNumber
                               rawPhoneNumber:(NSString *)rawPhoneNumber
                                  countryCode:(FUICountryCodeInfo *)countryCode {
  NSParameterAssert(normalizedPhoneNumber);
  NSParameterAssert(rawPhoneNumber);
  NSParameterAssert(countryCode);
  if (!normalizedPhoneNumber || !rawPhoneNumber || !countryCode){
    return nil;
  }
  if (self = [super init]) {
    _countryCode = countryCode;
    _rawPhoneNumber = rawPhoneNumber;
    _normalizedPhoneNumber = normalizedPhoneNumber;
  }
  return self;
}

- (instancetype)initWithRawPhoneNumber:(NSString *)rawPhoneNumber
                           countryCode:(FUICountryCodeInfo *)countryCode {
  NSString *dialCode = countryCode.dialCode;
  if ([dialCode characterAtIndex:0] != '+') {
    dialCode = [@"+" stringByAppendingString:dialCode];
  }
  NSString *normalizedPhoneNumber = [NSString stringWithFormat:@"%@%@", dialCode, rawPhoneNumber];
  
  return [self initWithNormalizedPhoneNumber:normalizedPhoneNumber
                              rawPhoneNumber:rawPhoneNumber
                                 countryCode:countryCode];
}

- (BOOL)validate:(NSError *__autoreleasing *)error {
  // The first character is always the '+'
  BOOL firstCharacterIsPlus = [self.normalizedPhoneNumber characterAtIndex:0] == '+';
  if (!firstCharacterIsPlus) {
    if (error) {
      *error = [NSError errorWithDomain:FUIPhoneNumberValidationErrorDomain
                                   code:FUIPhoneNumberValidationErrorMissingPlus
                               userInfo:nil];
    }
    return false;
  }
  BOOL containsMoreThanThePlus = self.normalizedPhoneNumber.length > 1;
  if (!containsMoreThanThePlus && error) {
    if (error) {
      *error = [NSError errorWithDomain:FUIPhoneNumberValidationErrorDomain
                                   code:FUIPhoneNumberValidationErrorMissingDialCode
                               userInfo:nil];
    }
    return false;
  }
  BOOL containsMoreThanTheCountryCode =
      self.normalizedPhoneNumber.length > 1 + self.countryCode.dialCode.length;
  if (!containsMoreThanTheCountryCode) {
    if (error) {
      *error = [NSError errorWithDomain:FUIPhoneNumberValidationErrorDomain
                                   code:FUIPhoneNumberValidationErrorMissingNumber userInfo:nil];
    }
    return false;
  }
  return true;
}

@end

NS_ASSUME_NONNULL_END
