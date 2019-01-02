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

@import UIKit;

#import <FirebaseStorage/FirebaseStorage.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImage+MultiFormat.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (FirebaseStorage)

/**
 * Returns the maximum image download size, in bytes. Defaults to 10e6.
 */
+ (UInt64)sd_defaultMaxImageSize;

/**
 * Sets the maximum image download size, in bytes.
 * @param size The new maximum image download size.
 */
+ (void)sd_setDefaultMaxImageSize:(UInt64)size;

/**
 * The current download task, if the image view is downloading an image.
 * Must be invoked on the main queue.
 */
@property (nonatomic, readonly, nullable) FIRStorageDownloadTask *sd_currentDownloadTask;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 * @return Returns a FIRStorageDownloadTask if a download was created (i.e. image
 *   could not be found in cache).
 */
- (nullable FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 * @param placeholder An image to display while the download is in progress.
 * @return Returns a FIRStorageDownloadTask if a download was created (i.e. image
 *   could not be found in cache).
 */
- (nullable FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                                    placeholderImage:(nullable UIImage *)placeholder;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 * @param placeholder An image to display while the download is in progress.
 * @param completion  A closure to handle events when the image finishes downloading.
 *   The closure is not guaranteed to be invoked on the main thread.
 * @return Returns a FIRStorageDownloadTask if a download was created (i.e. image
 *   could not be found in cache).
 */
- (nullable FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                                    placeholderImage:(nullable UIImage *)placeholder
                                                          completion:(void (^_Nullable)(UIImage *_Nullable,
                                                                                        NSError *_Nullable,
                                                                                        SDImageCacheType,
                                                                                        FIRStorageReference *))completion;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 * @param size        The maximum size of the downloaded image. If the downloaded image
 *   exceeds this size, an error will be raised in the completion block.
 * @param placeholder An image to display while the download is in progress.
 * @param completion  A closure to handle events when the image finishes downloading.
 *   The closure is not guaranteed to be invoked on the main thread.
 * @return Returns a FIRStorageDownloadTask if a download was created (i.e. image
 *   could not be found in cache).
 */
- (nullable FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                                        maxImageSize:(UInt64)size
                                                    placeholderImage:(nullable UIImage *)placeholder
                                                          completion:(void (^_Nullable)(UIImage *_Nullable,
                                                                                        NSError *_Nullable,
                                                                                        SDImageCacheType,
                                                                                        FIRStorageReference *))completion;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 * @param size        The maximum size of the downloaded image. If the downloaded image
 *   exceeds this size, an error will be raised in the completion block.
 * @param placeholder An image to display while the download is in progress.
 * @param cache       An image cache to check for images before downloading.
 * @param completion  A closure to handle events when the image finishes downloading.
 * @return Returns a FIRStorageDownloadTask if a download was created (i.e. image
 *   could not be found in cache).
 */
- (nullable FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                                        maxImageSize:(UInt64)size
                                                    placeholderImage:(nullable UIImage *)placeholder
                                                               cache:(nullable SDImageCache *)cache
                                                          completion:(void (^_Nullable)(UIImage *_Nullable,
                                                                                        NSError *_Nullable,
                                                                                        SDImageCacheType,
                                                                                        FIRStorageReference *))completion;

@end

NS_ASSUME_NONNULL_END
