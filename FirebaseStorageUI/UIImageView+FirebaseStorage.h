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
@import SDWebImage;
@import FirebaseStorage;

NS_ASSUME_NONNULL_BEGIN

@protocol FUIImageCache <NSObject>
@required

- (nullable UIImage *)imageFromMemoryCacheForKey:(NSString *)key;
- (nullable UIImage *)imageFromDiskCacheForKey:(NSString *)key;
- (void)storeImage:(UIImage *)image forKey:(NSString *)key;

@end

@protocol FUIDownloadTask <NSObject>
@required

- (void)cancel;

@end

@protocol FUIStorageReference <NSObject>
@required

@property (nonatomic, readonly) NSString *fullPath;

- (id<FUIDownloadTask>)dataWithMaxSize:(int64_t)size
                            completion:(void (^)(NSData *_Nullable data,
                                                 NSError *_Nullable error))completion;

@end

@interface FIRStorageReference (FirebaseUI) <FUIStorageReference>
@end

@interface FIRStorageDownloadTask (FirebaseUI) <FUIDownloadTask>
@end

@interface SDImageCache (FirebaseUI) <FUIImageCache>
@end

@interface UIImageView (FirebaseStorage)

/**
 * The current download task, if the image view is downloading an image.
 */
@property (nonatomic, readonly, nullable) id<FUIDownloadTask> sd_currentDownload;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 * @return Returns a FIRStorageDownloadTask if a download was created (i.e. image
 *   could not be found in cache).
 */
- (nullable id<FUIDownloadTask>)sd_setImageWithStorageReference:(id<FUIStorageReference>)storageRef;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 * @param placeholder An image to display while the download is in progress.
 * @return Returns a FIRStorageDownloadTask if a download was created (i.e. image
 *   could not be found in cache).
 */
- (nullable id<FUIDownloadTask>)sd_setImageWithStorageReference:(id<FUIStorageReference>)storageRef
                                                placeholderImage:(UIImage *)placeholder;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 * @param placeholder An image to display while the download is in progress.
 * @param completion  A closure to handle events when the image finishes downloading.
 *   The closure is not guaranteed to be invoked on the main thread.
 * @return Returns a FIRStorageDownloadTask if a download was created (i.e. image
 *   could not be found in cache).
 */
- (nullable id<FUIDownloadTask>)sd_setImageWithStorageReference:(id<FUIStorageReference>)storageRef
                                                placeholderImage:(nullable UIImage *)placeholder
                                                      completion:(void (^_Nullable)(UIImage *_Nullable,
                                                                                    NSError *_Nullable,
                                                                                    SDImageCacheType,
                                                                                    id<FUIStorageReference>))completion;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
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
- (nullable id<FUIDownloadTask>)sd_setImageWithStorageReference:(id<FUIStorageReference>)storageRef
                                                    maxImageSize:(UInt64)size
                                                placeholderImage:(nullable UIImage *)placeholder
                                                      completion:(void (^_Nullable)(UIImage *_Nullable,
                                                                                    NSError *_Nullable,
                                                                                    SDImageCacheType,
                                                                                    id<FUIStorageReference>))completion;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 * @param size        The maximum size of the downloaded image. If the downloaded image
 *   exceeds this size, an error will be raised in the completion block.
 * @param placeholder An image to display while the download is in progress.
 * @param cache       An image cache to check for images before downloading.
 * @param completion  A closure to handle events when the image finishes downloading.
 *   The closure is not guaranteed to be invoked on the main thread.
 * @return Returns a FIRStorageDownloadTask if a download was created (i.e. image
 *   could not be found in cache).
 */
- (nullable id<FUIDownloadTask>)sd_setImageWithStorageReference:(id<FUIStorageReference>)storageRef
                                                    maxImageSize:(UInt64)size
                                                placeholderImage:(nullable UIImage *)placeholder
                                                           cache:(nullable id<FUIImageCache>)cache
                                                      completion:(void (^_Nullable)(UIImage * _Nullable,
                                                                                    NSError * _Nullable,
                                                                                    SDImageCacheType,
                                                                                    id<FUIStorageReference>))completion;

@end

NS_ASSUME_NONNULL_END
