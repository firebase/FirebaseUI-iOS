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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/* Name of the FirebaseAuthUI resource bundle. */
extern NSString *const FUIAuthBundleName;

/** @class FUIAuthUtils
    @brief Provides utility methods for Firebase Auth UI.
 */
@interface FUIAuthUtils : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (NSBundle *)authUIBundle;

/** @fn bundleNamed:
    @brief Gets the framework bundle for specified name
    @param bundleName Name of the bundle to retreive. If nil, this returns the default bundle for
        FirebaseUI.
    @param framework The name of the framework module the resource bundle should be present in.
 */
+ (nullable NSBundle *)bundleNamed:(nullable NSString *)bundleName
                 inFrameworkBundle:(nullable NSBundle *)framework;

/** @fn imageNamed:fromBundle:
 @brief Gets a UIImage with the given name, assuming it's a png.
 @param name Name of the image to retreive.
 @param bundle The bundle to retrieve the image from. If nil, this method will look into the
     default FirebaseAuthUI framework bundle.
 */
+ (nullable UIImage *)imageNamed:(NSString *)name fromBundle:(nullable NSBundle *)bundle;

/** @fn randomNonce
    @brief Generates a random 32-character nonce.
 */
+ (NSString *)randomNonce;

/** @fn stringBySHA256HashingString:
    @brief Generates the SHA-256 hash of the input string.
    @param input The input string to be hashed.
 */
+ (NSString *)stringBySHA256HashingString:(NSString *)input;

@end

NS_ASSUME_NONNULL_END
