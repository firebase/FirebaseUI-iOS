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

#import <CommonCrypto/CommonCrypto.h>

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

+ (NSString *)randomNonce {
  // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
  NSString *characterSet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._";
  NSMutableString *result = [NSMutableString string];
  NSInteger remainingLength = 32;

  while (remainingLength > 0) {
    NSMutableArray *randoms = [NSMutableArray arrayWithCapacity:16];
    for (NSInteger i = 0; i < 16; i++) {
      uint8_t random = 0;
      int errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random);
      if (errorCode != errSecSuccess) {
        [NSException raise:@"FUIAuthGenerateRandomNonce"
                    format:@"Unable to generate nonce: OSStatus %i", errorCode];
      }

      [randoms addObject:@(random)];
    }

    for (NSNumber *random in randoms) {
      if (remainingLength == 0) {
        break;
      }

      if (random.unsignedIntValue < characterSet.length) {
        unichar character = [characterSet characterAtIndex:random.unsignedIntValue];
        [result appendFormat:@"%C", character];
        remainingLength--;
      }
    }
  }

  return result;
}

+ (NSString *)stringBySHA256HashingString:(NSString *)input {
  const char *string = [input UTF8String];
  unsigned char result[CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(string, (CC_LONG)strlen(string), result);

  NSMutableString *hashed = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
  for (NSInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
    [hashed appendFormat:@"%02x", result[i]];
  }
  return hashed;
}

@end
