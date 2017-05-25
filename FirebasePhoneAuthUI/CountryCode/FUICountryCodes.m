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

NSString* const FUI_JSON_COUNTRY_NAME_KEY = @"name";
NSString* const FUI_JSON_LOCALIZED_COUNTRY_NAME_KEY = @"localized_name";
NSString* const FUI_JSON_COUNTRY_CODE_KEY = @"iso2_cc";
NSString* const FUI_JSON_DIALCODE_KEY = @"e164_cc";
NSString* const FUI_JSON_LEVEL_KEY = @"level";
NSString* const FUI_JSON_COUNTRY_CODE_PREDICATE = @"(iso2_cc like[c] %@)";
NSString* const FUI_JSON_COUNTRY_NAME_PREDICATE = @"(localized_name beginswith[cd] %@)";
NSString* const FUIDefaultCountryCode = @"US";

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
@property (nonatomic, readonly) NSArray* countryCodesArray;
@end

@implementation FUICountryCodes

- (FUICountryCodes *)init {
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

- (FUICountryCodes *)initWithCountriesArray:(NSArray *)countries {
  NSParameterAssert(countries);

  if (!countries) {
    return nil;
  }

  if (self = [super init]) {
    _countryCodesArray = countries;

    [self localizeCountryCodesArray];
    [self sortCountryCodesArray];

  }
  return self;
}

- (NSUInteger)count {
  return [self.countryCodesArray count];
}

- (FUICountryCodeInfo*)countryCodeInfoForCode:(NSString*)countryCode {
  NSArray* filtered =
      [self.countryCodesArray filteredArrayUsingPredicate:
          [NSPredicate predicateWithFormat:FUI_JSON_COUNTRY_CODE_PREDICATE, countryCode]];
  if ([filtered count] != 1) {
    return nil;
  }
  NSDictionary* match = filtered[0];

  return [self countryCodeInfoForDictionary:match];
}

- (FUICountryCodeInfo*)countryCodeInfoForRow:(NSInteger)row {
  NSDictionary* match = [self.countryCodesArray objectAtIndex:row];

  return [self countryCodeInfoForDictionary:match];
}

- (FUICountryCodeInfo *)countryCodeInfoFromDeviceLocale {
  CTCarrier *carrier = [[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider];
  NSString *countryCode = carrier.isoCountryCode ?: [[self class] countryCodeFromDeviceLocale];
  FUICountryCodeInfo* countryCodeInfo = [self countryCodeInfoForCode:countryCode];
  return countryCodeInfo ?: [self countryCodeInfoForCode:FUIDefaultCountryCode];
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

- (FUICountryCodes *)searchCountriesByName:(NSString *)countryName {
  if ([countryName length] == 0) {
    return nil;
  } else {
    NSArray *results =
        [self.countryCodesArray filteredArrayUsingPredicate:
            [NSPredicate predicateWithFormat:FUI_JSON_COUNTRY_NAME_PREDICATE, countryName]];
    return [[FUICountryCodes alloc] initWithCountriesArray:results];
  }
}

#pragma mark Helper methods

- (FUICountryCodeInfo *)countryCodeInfoForDictionary:(NSDictionary *)dictionary {
  FUICountryCodeInfo* countryCodeInfo = [[FUICountryCodeInfo alloc] init];
  countryCodeInfo.countryName = dictionary[FUI_JSON_COUNTRY_NAME_KEY];
  countryCodeInfo.countryCode = dictionary[FUI_JSON_COUNTRY_CODE_KEY];
  countryCodeInfo.localizedCountryName = dictionary[FUI_JSON_LOCALIZED_COUNTRY_NAME_KEY];
  countryCodeInfo.dialCode = dictionary[FUI_JSON_DIALCODE_KEY];
  countryCodeInfo.level = dictionary[FUI_JSON_LEVEL_KEY];

  return countryCodeInfo;
}

- (void)localizeCountryCodesArray {
  NSMutableArray *array = [NSMutableArray new];
  for (NSDictionary *dict in self.countryCodesArray) {
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSString *localizedCountryName =
        [FUICountryCodes localizedCountryNameForCountryCode:dict[FUI_JSON_COUNTRY_CODE_KEY]];
    if (localizedCountryName == nil) {
      localizedCountryName = dict[FUI_JSON_COUNTRY_NAME_KEY];
    }
    [newDict setValue:localizedCountryName forKey:FUI_JSON_LOCALIZED_COUNTRY_NAME_KEY];
    [array addObject:newDict];
  }
  _countryCodesArray = array;
}

- (void)sortCountryCodesArray {
  NSSortDescriptor *descriptor =
      [[NSSortDescriptor alloc] initWithKey:FUI_JSON_LOCALIZED_COUNTRY_NAME_KEY
                                  ascending:YES
                                   selector:@selector(localizedCaseInsensitiveCompare:)];
  _countryCodesArray = [self.countryCodesArray sortedArrayUsingDescriptors:
                          [NSArray arrayWithObjects:descriptor, nil]];
}

- (NSDictionary *)countryCodesByDialCode {
  NSMutableDictionary *countryCodes =
    [NSMutableDictionary dictionaryWithCapacity:self.countryCodesArray.count];

  for (NSDictionary *dict in self.countryCodesArray) {
    NSString *dialCode = dict[FUI_JSON_DIALCODE_KEY];
    NSNumber *level = dict[FUI_JSON_LEVEL_KEY];

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
  NSString *countryCode = FUIDefaultCountryCode;
  NSLocale *currentLocale = [NSLocale currentLocale];
  if (currentLocale) {
    countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
  }
  return countryCode;
}

@end

NS_ASSUME_NONNULL_END
