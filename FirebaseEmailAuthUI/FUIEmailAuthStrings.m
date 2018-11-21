//
//  Copyright (c) 2018 Google Inc.
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

#import "FUIEmailAuthStrings.h"

#import "FUIAuthStrings.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const FUIEmailAuthBundleName = @"FirebaseEmailAuthUI";

/** @var kEmailAuthProviderTableName
    @brief The name of the strings table to search for localized strings.
 */
NSString *const kEmailAuthProviderTableName = @"FirebaseEmailAuthUI";

NSString *FUIEmailAuthLocalizedString(NSString *key) {
  return FUILocalizedStringFromTableInBundle(key,
                                             kEmailAuthProviderTableName,
                                             FUIEmailAuthBundleName);
}

NS_ASSUME_NONNULL_END
