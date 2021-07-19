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

#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthUtils.h"

#if SWIFT_PACKAGE
NSString *const FUIAuthBundleName = @"FirebaseUI_FirebaseAuthUI";
#else
NSString *const FUIAuthBundleName = @"FirebaseAuthUI";
#endif // SWIFT_PACKAGE

@implementation FUIAuthUtils

+ (NSBundle *)authUIBundle {
  return [self bundleNamed:FUIAuthBundleName
         inFrameworkBundle:[NSBundle bundleForClass:[self class]]];
}

+ (nullable NSBundle *)bundleNamed:(nullable NSString *)bundleName
                 inFrameworkBundle:(nullable NSBundle *)framework {
  NSBundle *returnBundle = nil;
  if (!bundleName) {
    bundleName = FUIAuthBundleName;
  }
  // Use the main bundle as a default if the framework wasn't provided.
  NSBundle *frameworkBundle = framework;
  if (frameworkBundle == nil) {
    // If frameworkBundle is unspecified, assume main bundle/static linking.
    frameworkBundle = [NSBundle mainBundle];
  }
  // If using static frameworks, the bundle will be included directly in the main
  // bundle.
  NSString *path = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];

  // Otherwise, check the appropriate framework bundle.
  if (!path) {
    path = [frameworkBundle pathForResource:bundleName ofType:@"bundle"];
  }
  if (!path) {
    NSLog(@"Warning: Unable to find bundle %@ in framework %@.", bundleName, framework);
    // Fall back on the root module.
    return frameworkBundle;
  }
  returnBundle = [NSBundle bundleWithPath:path];
  return returnBundle;
}

+ (nullable UIImage *)imageNamed:(NSString *)name fromBundle:(nullable NSBundle *)bundle {
  if (!bundle) {
    bundle = [self authUIBundle];
  }
  if (@available(iOS 13.0, *)) {
    return [UIImage imageNamed:name inBundle:bundle withConfiguration:nil];
  } else {
    NSString *path = [bundle pathForResource:name ofType:@"png"];
    if (!path) {
      NSLog(@"Warning: Unable to find asset %@ in bundle %@.", name, bundle);
      return nil;
    }
    return [UIImage imageWithContentsOfFile:path];
  }
}

@end
