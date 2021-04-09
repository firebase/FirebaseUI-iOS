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
#import "FUIStorageDefine.h"
#import "NSURL+FirebaseStorage.h"

NS_ASSUME_NONNULL_BEGIN

/*
 * This Firebase Storage loader is used to load a `Firebase Storage reference` of image record.
 * To use the Firebase Storage loader, you can use the API in `UIImageView+FirebaseStorage.h` for simple usage.
 * You can also use the native SDWebImage's View Category API, with the URL constructed with `FIRStorageReference`. See `NSURL+FirebaseStorage.h`
 * @code
 // Supports HTTP URL as well as Firebase Storage URL globally. Put this in the early setup step like AppDelegate.m
 SDImageLoadersManager.loaders = @[SDWebImageDownloader.sharedDownloader, FUIStorageImageLoader.sharedLoader];
 // Replace default manager's loader implementation
 SDWebImageManager.defaultImageLoader = SDImageLoadersManager.sharedManager;
 
 // Then you can simply call SDWebImage's APIs the same as normal HTTP URL
 FIRStorageReference *storageRef;
 NSURL *url = [NSURL sd_URLWithStorageReference:storageRef];
 [imageView sd_setImageWithURL:url];
 * @endcode
 */
NS_SWIFT_NAME(StorageImageLoader)
@interface FUIStorageImageLoader : NSObject<SDImageLoader>

/**
 * The maximum image download size, in bytes. Defaults to 10e6.
 */
@property (nonatomic, assign) UInt64 defaultMaxImageSize;

/**
 The global shared instance for Firebase Storage loader.
 */
@property (nonatomic, class, readonly, nonnull) FUIStorageImageLoader *sharedLoader;

@end

NS_ASSUME_NONNULL_END
