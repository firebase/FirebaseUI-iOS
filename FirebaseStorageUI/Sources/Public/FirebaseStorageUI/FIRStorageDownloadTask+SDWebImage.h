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

#import <SDWebImage/SDWebImage.h>

// The category declaration requires FIRStorageDownloadTask to be fully defined,
// which is only possible when the CocoaPods-style headers are present.
// For SPM builds the declaration (and @import FirebaseStorage) live in the .m file
// so the Clang module scanner never sees @import here.
#if __has_include(<FirebaseStorage/FirebaseStorage.h>)
  // Firebase 8.x (CocoaPods)
  #import <FirebaseStorage/FirebaseStorage.h>
  NS_ASSUME_NONNULL_BEGIN
  @interface FIRStorageDownloadTask (SDWebImage) <SDWebImageOperation>
  @end
  NS_ASSUME_NONNULL_END
#elif __has_include(<FirebaseStorage/FirebaseStorage-Swift.h>)
  // Firebase 9.0+ (CocoaPods)
  #import <FirebaseStorage/FirebaseStorage-Swift.h>
  NS_ASSUME_NONNULL_BEGIN
  @interface FIRStorageDownloadTask (SDWebImage) <SDWebImageOperation>
  @end
  NS_ASSUME_NONNULL_END
#endif
