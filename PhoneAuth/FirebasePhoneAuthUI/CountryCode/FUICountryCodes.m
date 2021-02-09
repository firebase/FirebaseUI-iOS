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

#import "FUICountryCodes.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "FUIAuthUtils.h"
#import "FUIPhoneAuthStrings.h"

NS_ASSUME_NONNULL_BEGIN

NSString* const kFUIJSONCountryNameKey = @"name";
NSString* const kFUIJSONLocalizedCountryNameKey = @"localized_name";
NSString* const kFUIJSONCountryCodeKey = @"iso2_cc";
NSString* const kFUIJSONDialcodeKey = @"e164_cc";
NSString* const kFUIJSONLevelKey = @"level";
NSString* const kFUIJSONCountryCodePredicate = @"(iso2_cc like[c] %@)";
NSString* const kFUIJSONCountryNamePredicate = @"(localized_name beginswith[cd] %@)";
NSString* const kFUIDefaultCountryCode = @"US";

@implementation FUICountryCodeInfo

- (NSString *)countryFlagEmoji {
  NSAssert(self.countryCode.length == 2, @"Expecting ISO country code");
  if (self.countryCode.length != 2) {
    return nil;
  }

  // Unicode offset for regional characters.
  // Country code flag emoji are the result of the combination of the two regional characters
  // that make up that country's two-character code.
  // https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
  const int base = 127397;

  const wchar_t bytes[2] = {
    base + [self.countryCode characterAtIndex:0],
    base + [self.countryCode characterAtIndex:1]
  };

  return [[NSString alloc] initWithBytes:bytes
                                  length:sizeof(bytes)
                                encoding:NSUTF32LittleEndianStringEncoding];
}
@end

@interface FUICountryCodes ()
@property (nonatomic, readonly) NSArray<NSDictionary *> *countryCodesArray;
@end

@implementation FUICountryCodes

- (instancetype)init {
  if (self = [super init]) {
    // Country codes JSON containing country codes and phone number info.
    NSString *countryCodeFilePath =
        [[FUIAuthUtils bundleNamed:FUIPhoneAuthBundleName] pathForResource:@"country-codes"
                                                                    ofType:@"json"];
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:countryCodeFilePath],
             @"Could not find country code file");

    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:countryCodeFilePath];
    [inputStream open];

    NSError* error = nil;
    _countryCodesArray =
        [NSJSONSerialization JSONObjectWithStream:inputStream
                                          options:NSJSONReadingMutableContainers
                                            error:&error];

    [inputStream close];

    NSAssert(error == nil, @"Could not parse country codes JSON");

    [self localizeCountryCodesArray];
    [self sortCountryCodesArray];
  }
  return self;
}

- (NSUInteger)count {
  return [self.countryCodesArray count];
}

- (nullable FUICountryCodeInfo *)countryCodeInfoForCode:(NSString *)countryCode {
  NSArray *filtered =
      [self.countryCodesArray filteredArrayUsingPredicate:
          [NSPredicate predicateWithFormat:kFUIJSONCountryCodePredicate, countryCode]];
  if (filtered.count != 1) {
    return nil;
  }
  NSDictionary *match = filtered[0];

  return [self countryCodeInfoForDictionary:match];
}

- (FUICountryCodeInfo *)countryCodeInfoAtIndex:(NSInteger)index {
  NSDictionary *match = [self.countryCodesArray objectAtIndex:index];
  return [self countryCodeInfoForDictionary:match];
}

- (FUICountryCodeInfo *)defaultCountryCodeInfo {
  // Get the country code based on the information of user's telecommunication carrier provider.
  CTCarrier *carrier;
  if (@available(iOS 12, *)) {
    NSDictionary *carriers =
        [[[CTTelephonyNetworkInfo alloc] init] serviceSubscriberCellularProviders];
    // For multi-sim phones, use the current locale to make an educated guess for
    // which carrier to use.
    NSString *currentCountryCode = [NSLocale currentLocale].countryCode;
    for (CTCarrier *provider in carriers.allValues) {
      if ([provider isKindOfClass:[CTCarrier class]] &&
          [provider.isoCountryCode isEqualToString:currentCountryCode]) {
        carrier = provider;
        break;
      }
    }

    // If the carrier is still nil, grab a random carrier from the dictionary.
    if (carrier == nil) {
      for (CTCarrier *provider in carriers.allValues) {
        if ([provider isKindOfClass:[CTCarrier class]]) {
          carrier = provider;
          break;
        }
      }
    }
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    carrier = [[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider];
#pragma clang diagnostic pop
  }
  NSString *countryCode = carrier.isoCountryCode ?: [[self class] countryCodeFromDeviceLocale];
  FUICountryCodeInfo *countryCodeInfo = [self countryCodeInfoForCode:countryCode];
  // If carrier is not available, get the hard coded default country code.
  if (!countryCodeInfo) {
    countryCodeInfo = [self countryCodeInfoForCode:kFUIDefaultCountryCode];
  }
  // If the hard coded default country code is not available, get the first available country code.
  if (!countryCodeInfo) {
    countryCodeInfo = [self countryCodeInfoAtIndex:0];
  }
  return countryCodeInfo;
}

- (FUICountryCodeInfo *)countryCodeInfoForPhoneNumber:(NSString *)phoneNumber {
  if (phoneNumber.length == 0 || [phoneNumber characterAtIndex:0] != '+') {
    return nil;
  }

  phoneNumber = [phoneNumber substringFromIndex:1];

  NSDictionary *countryCodes = [self countryCodesByDialCode];
  const NSUInteger maxCountryCodeLengh = 3;

  for (NSUInteger i = maxCountryCodeLengh; i > 0; i -= 1) {
    if (phoneNumber.length < i) {
      continue;
    }

    NSString *candidateDialCode = [phoneNumber substringToIndex:i];

    if (countryCodes[candidateDialCode]) {
      return countryCodes[candidateDialCode];
    }
  }

  return nil;
}

- (void)blacklistCountries:(NSSet<NSString *> *)countries {
  NSMutableArray<NSDictionary *> *array =
      [[NSMutableArray alloc] initWithCapacity:_countryCodesArray.count];
  for (NSDictionary *dict in self.countryCodesArray) {
    NSString *countryCode = dict[kFUIJSONCountryCodeKey];
    NSString *dialCode = dict[kFUIJSONDialcodeKey];
    if ([countries containsObject:countryCode] || [countries containsObject:dialCode]) {
      continue;
    }
    [array addObject:dict];
  }
  _countryCodesArray = array.mutableCopy;
}

- (void)whitelistCountries:(NSSet<NSString *> *)countries {
  NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:countries.count];
  for (NSDictionary *dict in self.countryCodesArray) {
    NSString *countryCode = dict[kFUIJSONCountryCodeKey];
    NSString *dialCode = dict[kFUIJSONDialcodeKey];
    if ([countries containsObject:countryCode] || [countries containsObject:dialCode]) {
      [array addObject:dict];
    }
  }
  _countryCodesArray = array.mutableCopy;
}

- (instancetype)searchCountriesByName:(NSString *)nameQuery {
  NSArray<NSDictionary *> *results =
      [self.countryCodesArray filteredArrayUsingPredicate:
          [NSPredicate predicateWithFormat:kFUIJSONCountryNamePredicate, nameQuery]];
  return [[FUICountryCodes alloc] initWithCountriesArray:results];
}

#pragma mark Helper methods

- (instancetype)initWithCountriesArray:(NSArray<NSDictionary *> *)countries {
  NSParameterAssert(countries);

  if (self = [super init]) {
    _countryCodesArray = countries;

    [self localizeCountryCodesArray];
    [self sortCountryCodesArray];

  }
  return self;
}

- (FUICountryCodeInfo *)countryCodeInfoForDictionary:(NSDictionary *)dictionary {
  FUICountryCodeInfo* countryCodeInfo = [[FUICountryCodeInfo alloc] init];
  countryCodeInfo.countryName = dictionary[kFUIJSONCountryNameKey];
  countryCodeInfo.countryCode = dictionary[kFUIJSONCountryCodeKey];
  countryCodeInfo.localizedCountryName = dictionary[kFUIJSONLocalizedCountryNameKey];
  countryCodeInfo.dialCode = dictionary[kFUIJSONDialcodeKey];
  countryCodeInfo.level = dictionary[kFUIJSONLevelKey];

  return countryCodeInfo;
}

- (void)localizeCountryCodesArray {
  NSMutableArray *array = [NSMutableArray new];
  for (NSDictionary *dict in self.countryCodesArray) {
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSString *localizedCountryName =
        [FUICountryCodes localizedCountryNameForCountryCode:dict[kFUIJSONCountryCodeKey]];
    if (localizedCountryName == nil) {
      localizedCountryName = dict[kFUIJSONCountryNameKey];
    }
    [newDict setValue:localizedCountryName forKey:kFUIJSONLocalizedCountryNameKey];
    [array addObject:newDict];
  }
  _countryCodesArray = array;
}

- (void)sortCountryCodesArray {
  NSSortDescriptor *descriptor =
      [[NSSortDescriptor alloc] initWithKey:kFUIJSONLocalizedCountryNameKey
                                  ascending:YES
                                   selector:@selector(localizedCaseInsensitiveCompare:)];
  _countryCodesArray = [self.countryCodesArray sortedArrayUsingDescriptors:
                          [NSArray arrayWithObjects:descriptor, nil]];
}

- (NSDictionary *)countryCodesByDialCode {
  NSMutableDictionary *countryCodes =
    [NSMutableDictionary dictionaryWithCapacity:self.countryCodesArray.count];

  for (NSDictionary *dict in self.countryCodesArray) {
    NSString *dialCode = dict[kFUIJSONDialcodeKey];
    NSNumber *level = dict[kFUIJSONLevelKey];

    if (!countryCodes[dialCode]) {
      countryCodes[dialCode] = [self countryCodeInfoForDictionary:dict];
    } else if (level) {
      FUICountryCodeInfo *existing = countryCodes[dialCode];

      if (level.integerValue < existing.level.integerValue) {
        countryCodes[dialCode] = [self countryCodeInfoForDictionary:dict];
      }
    }
  }

  return countryCodes;
}

+ (NSString *)localizedCountryNameForCountryCode:(NSString *)countryCode {
  NSLocale *locale = [NSLocale currentLocale];
  NSString *localizedCountryName = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
  return localizedCountryName;
}

+ (NSString *)countryCodeFromDeviceLocale {
  NSString *countryCode = kFUIDefaultCountryCode;
  NSLocale *currentLocale = [NSLocale currentLocale];
  if (currentLocale) {
    countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
  }
  return countryCode;
}

@end

NS_ASSUME_NONNULL_END
