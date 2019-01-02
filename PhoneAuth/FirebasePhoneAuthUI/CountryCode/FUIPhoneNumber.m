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

#import "FUICountryCodes.h"

NSString * const FUIPhoneNumberValidationErrorDomain = @"FUIPhoneNumberValidationErrorDomain";

NS_ASSUME_NONNULL_BEGIN

@implementation FUIPhoneNumber

- (instancetype)initWithNormalizedPhoneNumber:(NSString *)normalizedPhoneNumber
                                 countryCodes:(FUICountryCodes *)countryCodes {
  NSAssert(normalizedPhoneNumber, @"normalizedPhoneNumber can't be nil");
  NSString *rawPhoneNumber;
  FUICountryCodeInfo *countryCode =
      [countryCodes countryCodeInfoForPhoneNumber:normalizedPhoneNumber];

  if (countryCode) {
    // Add 1 for the '+' character
    NSInteger countryCodeLength = countryCode.dialCode.length + 1;
    if (normalizedPhoneNumber.length >= countryCodeLength) {
      rawPhoneNumber = [normalizedPhoneNumber substringFromIndex:countryCodeLength];
    }
  }
  if (!rawPhoneNumber) {
    rawPhoneNumber = normalizedPhoneNumber;
    countryCode = [countryCodes defaultCountryCodeInfo];
  }
  return [self initWithRawPhoneNumber:rawPhoneNumber countryCode:countryCode];
}

- (instancetype)initWithNormalizedPhoneNumber:(NSString *)normalizedPhoneNumber
                               rawPhoneNumber:(NSString *)rawPhoneNumber
                                  countryCode:(FUICountryCodeInfo *)countryCode {
  NSAssert(normalizedPhoneNumber, @"normalizedPhoneNumber can't be nil");
  NSAssert(rawPhoneNumber, @"rawPhoneNumber can't be nil");
  NSAssert(countryCode, @"countryCode can't be nil");
  if (self = [super init]) {
    _countryCode = countryCode;
    _rawPhoneNumber = rawPhoneNumber;
    _normalizedPhoneNumber = normalizedPhoneNumber;
  }
  return self;
}

- (instancetype)initWithRawPhoneNumber:(NSString *)rawPhoneNumber
                           countryCode:(FUICountryCodeInfo *)countryCode {
  NSAssert(rawPhoneNumber, @"rawPhoneNumber can't be nil");
  NSAssert(countryCode, @"countryCode can't be nil");
  NSString *dialCode = countryCode.dialCode;
  NSAssert(dialCode.length, @"dialCode can't be empty");
  if ([dialCode characterAtIndex:0] != '+') {
    dialCode = [@"+" stringByAppendingString:dialCode];
  }
  NSString *normalizedPhoneNumber = [NSString stringWithFormat:@"%@%@", dialCode, rawPhoneNumber];
  
  return [self initWithNormalizedPhoneNumber:normalizedPhoneNumber
                              rawPhoneNumber:rawPhoneNumber
                                 countryCode:countryCode];
}

- (BOOL)validate:(NSError *__autoreleasing _Nullable *_Nullable)errorRef {
  // The first character is always the '+'
  BOOL firstCharacterIsPlus = [_normalizedPhoneNumber characterAtIndex:0] == '+';
  if (!firstCharacterIsPlus) {
    if (errorRef) {
      NSString *message = [NSString stringWithFormat:@"Phone number %@ should start with '+'",
                              _normalizedPhoneNumber];
      NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : message };
      *errorRef = [NSError errorWithDomain:FUIPhoneNumberValidationErrorDomain
                                      code:FUIPhoneNumberValidationErrorMissingPlus
                                  userInfo:userInfo];
    }
    return false;
  }
  BOOL containsMoreThanThePlus = self.normalizedPhoneNumber.length > 1;
  if (!containsMoreThanThePlus) {
    if (errorRef) {
      NSString *message = [NSString stringWithFormat:@"Phone number %@ should have only one '+'",
                              _normalizedPhoneNumber];
      NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : message };
      *errorRef = [NSError errorWithDomain:FUIPhoneNumberValidationErrorDomain
                                      code:FUIPhoneNumberValidationErrorMissingDialCode
                                  userInfo:userInfo];
    }
    return false;
  }
  BOOL containsMoreThanTheCountryCode =
      self.normalizedPhoneNumber.length > 1 + self.countryCode.dialCode.length;
  if (!containsMoreThanTheCountryCode) {
    if (errorRef) {
      NSString *message =
          [NSString stringWithFormat:@"Phone number %@ should have only one country code",
              _normalizedPhoneNumber];
      NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : message };
      *errorRef = [NSError errorWithDomain:FUIPhoneNumberValidationErrorDomain
                                      code:FUIPhoneNumberValidationErrorMissingNumber
                                  userInfo:userInfo];
    }
    return false;
  }
  return true;
}

@end

NS_ASSUME_NONNULL_END
