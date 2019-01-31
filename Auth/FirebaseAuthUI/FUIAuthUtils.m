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

#import "FUIAuthUtils.h"

NSString *const FUIAuthBundleName = @"FirebaseAuthUI";

@implementation FUIAuthUtils

+ (NSBundle *)bundleNamed:(NSString *)bundleName {
  NSBundle *frameworkBundle = nil;
  if (!bundleName) {
    bundleName = FUIAuthBundleName;
  }
  NSString *path = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
  if (!path) {
    // Check framework resources if bundle isn't present in main bundle.
    path = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"framework"];
  }
  frameworkBundle = [NSBundle bundleWithPath:path];
  if (!frameworkBundle) {
    frameworkBundle = [NSBundle bundleForClass:[self class]];
  }
  return frameworkBundle;
}

+ (UIImage *)imageNamed:(NSString *)name fromBundle:(NSBundle *)bundle {
  if (!bundle) {
    bundle = [self bundleNamed:nil];
  }
  NSString *path = [bundle pathForResource:name ofType:@"png"];
  if (!path) {
    NSLog(@"Warning: Unable to find asset %@ in bundle %@.", name, bundle);
  }
  return [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *)imageNamed:(NSString *)name fromBundleNameOrNil:(nullable NSString *)bundleNameOrNil {
  NSString *path = [[FUIAuthUtils bundleNamed:bundleNameOrNil] pathForResource:name ofType:@"png"];
  if (!path) {
    NSLog(@"Warning: Unable to find asset %@ in bundle named %@.", name, bundleNameOrNil);
  }
  return [UIImage imageWithContentsOfFile:path];
}

+ (BOOL)isFirebasePerformanceAvailable {
  return NSClassFromString(@"FIRPerformance") != nil;
}

@end
