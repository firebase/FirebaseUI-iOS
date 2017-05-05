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

#import "FUIFeatureSwitch.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FUIFeatureSwitch
+ (BOOL)isCountryFlagEmojiEnabled {
  static BOOL useEmoji = false;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Cutoff version of using country flag emoji is ios 8.4
    static NSOperatingSystemVersion ios8_4_0 = (NSOperatingSystemVersion){8, 4, 0};
    useEmoji = [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios8_4_0];
  });
  return useEmoji;
}
@end

NS_ASSUME_NONNULL_END
