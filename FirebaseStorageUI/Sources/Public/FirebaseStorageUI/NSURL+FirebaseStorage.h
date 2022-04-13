//
//  Copyright (c) 2019 Google Inc.
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

#if __has_include(<FirebaseStorage/FirebaseStorage.h>)
  // Firebase 8.x
  #import <FirebaseStorage/FirebaseStorage.h>
#else
  // Firebase 9.0+
  #import <FirebaseStorage/FirebaseStorage-Swift.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (FirebaseStorage)

/**
 The `FIRStorageReference` value for Firebase Storage reference, or nil for other URL.
 */
@property (nonatomic, strong, readonly, nullable) FIRStorageReference *sd_storageReference;

/**
 Create a Firebase Storage reference URL with `FIRStorageReference`
 
 @param storageRef `FIRStorageReference` object
 @return A Firebase Storage reference URL
 */
+ (nullable instancetype)sd_URLWithStorageReference:(nonnull FIRStorageReference *)storageRef;

@end

NS_ASSUME_NONNULL_END
