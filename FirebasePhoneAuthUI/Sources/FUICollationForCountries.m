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

#import "FirebasePhoneAuthUI/Sources/FUICollationForCountries.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FUICollationForCountries ()

@property (nonatomic, readonly) FUICountryCodes *countryCodes;
@property (nonatomic, readonly, copy) NSArray *sectionTitlesArray;

@end

@implementation FUICollationForCountries

- (instancetype)initWithCountryCodes:(FUICountryCodes *)countryCodes {
  if (self = [super init]) {
    _countryCodes = countryCodes;

    // Apple's default collation ordering is not lexically sorted, so fix it
    NSArray *sortedSectionTitlesArray =
        [[[UILocalizedIndexedCollation currentCollation] sectionTitles]
            sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    // Remove section indices with zero countries in it
    NSIndexSet *indexesOfFilteredArray =
        [sortedSectionTitlesArray indexesOfObjectsPassingTest:
            ^BOOL(id obj, NSUInteger sectionIndex, BOOL *stop) {
      BOOL sectionHasCountries =
          [self numberOfCountriesInSection:sectionIndex titlesArray:sortedSectionTitlesArray] > 0;
      return sectionHasCountries;
    }];
    _sectionTitlesArray = [sortedSectionTitlesArray objectsAtIndexes:indexesOfFilteredArray];
  }
  return self;
}

- (NSArray *)sectionTitles {
  return self.sectionTitlesArray;
}

- (NSArray *)sectionIndexTitles {
  return self.sectionTitlesArray;
}

- (NSInteger)numberOfCountriesInSection:(NSInteger)sectionIndex {
  return [self numberOfCountriesInSection:sectionIndex titlesArray:self.sectionTitlesArray];
}

- (NSInteger)numberOfCountriesInSection:(NSInteger)sectionIndex titlesArray:(NSArray *)titlesArray {
  // sectionTitle and nextSectionTitle are e.g. "A" and "B"
  // However when sectionTitle is the last available section (e.g. "Z"), nextSectionTitle is the
  // last unicode char available (\uFFFF). This is to ensure all remaining countries are lexically
  // smaller than that section, so that all remaining countries fall in sectionTitle
  NSString *sectionTitle = [titlesArray objectAtIndex:sectionIndex];
  NSString *nextSectionTitle =
      (sectionIndex+1 < titlesArray.count) ? [titlesArray objectAtIndex:(sectionIndex+1)]
                                           : @"\uFFFF";

  NSInteger countriesInSection = 0;
  for (NSInteger row = 0; row < self.countryCodes.count; row++) {
    NSString* localizedCountryName =
        [self.countryCodes countryCodeInfoAtIndex:row].localizedCountryName;
    BOOL countryNameIsInBetweenTitles =
        ([sectionTitle localizedCaseInsensitiveCompare:localizedCountryName] == NSOrderedAscending
             && [nextSectionTitle localizedCaseInsensitiveCompare:localizedCountryName] ==
                 NSOrderedDescending);
    BOOL countryNameIsPastTitles =
        [nextSectionTitle localizedCaseInsensitiveCompare:localizedCountryName] ==
            NSOrderedAscending;

    if (countryNameIsInBetweenTitles) {
      countriesInSection++;
    } else if (countryNameIsPastTitles) {
      break;
    }
  }

  return countriesInSection;
}

@end

NS_ASSUME_NONNULL_END
