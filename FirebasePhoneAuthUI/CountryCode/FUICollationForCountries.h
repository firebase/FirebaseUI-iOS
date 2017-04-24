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

/** @class FUICollationForCountries
    @brief Replacement class for UILocalizedIndexedCollation tailored to FUICountryCodes, used to 
        create UITableView alphabetical indices. Main difference from UILocalizedIndexedCollation 
        is sectionTitles and sectionIndexTitles methods remove sections with zero countries in them.
 */
@interface FUICollationForCountries : NSObject

- (instancetype)initWithCountryCodes:(FUICountryCodes *)countryCodes NS_DESIGNATED_INITIALIZER;
+ (instancetype)new __unavailable;
- (instancetype)init __unavailable;

/** @fn sectionTitles
    @brief Drop-in replacement for [UILocalizedIndexedCollation sectionTitles]
 */
- (NSArray *)sectionTitles;

/** @fn sectionIndexTitles
    @brief Drop-in replacement for [UILocalizedIndexedCollation sectionIndexTitles]
 */
- (NSArray *)sectionIndexTitles;

/** @fn numberOfCountriesInSection:
    @brief Returns number of countries that belong to a given alphabetical section (e.g. how many 
        countries are there in section "A"). Works by counting how many countries are lexically 
        greater than the section but smaller than the next section (e.g. how many countries are 
        greater than "A" but smaller than "B").
    @param sectionIndex Index of the section.
    @return Returns number of countries.
 */
- (NSInteger)numberOfCountriesInSection:(NSInteger)sectionIndex;

@end

NS_ASSUME_NONNULL_END
