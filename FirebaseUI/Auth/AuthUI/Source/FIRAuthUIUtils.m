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

#import "FIRAuthUIUtils.h"

#import <CoreText/CoreText.h>

@implementation FIRAuthUIUtils

+ (NSBundle *)frameworkBundle {
  static NSBundle *frameworkBundle = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
    NSString *frameworkBundlePath =
        [mainBundlePath stringByAppendingPathComponent:@"FirebaseAuthUIBundle.bundle"];
    frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    if (!frameworkBundle) {
      frameworkBundle = [NSBundle mainBundle];
    }
  });
  return frameworkBundle;
}

+ (UIImage *)imageNamed:(NSString *)name {
  NSString *path = [[[self class] frameworkBundle] pathForResource:name ofType:@"png"];
  return [UIImage imageWithContentsOfFile:path];
}

+ (NSURL *)URLWithString:(NSString *)urlString queryParameters:(NSDictionary *)queryParameters {
  if ([urlString length] == 0) return nil;

  NSString *fullURLString;
  if ([queryParameters count] > 0) {
    NSMutableArray *queryItems = [NSMutableArray arrayWithCapacity:[queryParameters count]];

    // sort the custom parameter keys so that we have deterministic parameter
    // order for unit tests
    NSArray *queryKeys = [queryParameters allKeys];
    NSArray *sortedQueryKeys =
        [queryKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

    for (NSString *paramKey in sortedQueryKeys) {
      NSString *paramValue = [queryParameters valueForKey:paramKey];

      NSString *paramItem = [NSString stringWithFormat:@"%@=%@",
                             [self stringByURLEncodingStringParameter:paramKey],
                             [self stringByURLEncodingStringParameter:paramValue]];

      [queryItems addObject:paramItem];
    }

    NSString *paramStr = [queryItems componentsJoinedByString:@"&"];

    BOOL hasQMark = ([urlString rangeOfString:@"?"].location == NSNotFound);
    char joiner = hasQMark ? '?' : '&';
    fullURLString = [NSString stringWithFormat:@"%@%c%@",
                     urlString, joiner, paramStr];
  } else {
    fullURLString = urlString;
  }
  NSURL *result = [NSURL URLWithString:fullURLString];
  return result;
}

+ (NSString *)stringByURLEncodingStringParameter:(NSString *)originalString {
  // For parameters, we'll explicitly leave spaces unescaped now, and replace
  // them with +'s
  NSString *const kForceEscape = @"!*'();:@&=+$,/?%#[]";
  NSString *const kLeaveUnescaped = @" ";

  NSMutableCharacterSet *cs = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
  [cs removeCharactersInString:kForceEscape];
  [cs addCharactersInString:kLeaveUnescaped];

  NSString *escapedStr = [originalString stringByAddingPercentEncodingWithAllowedCharacters:cs];
  NSString *resultStr = originalString;
  if (escapedStr) {
    // replace spaces with plusses
    resultStr = [escapedStr stringByReplacingOccurrencesOfString:@" "
                                                      withString:@"+"];
  }
  return resultStr;
}

@end
