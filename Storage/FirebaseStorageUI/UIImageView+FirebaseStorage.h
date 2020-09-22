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

#import <UIKit/UIKit.h>

#import <FirebaseStorage/FirebaseStorage.h>
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN


/**
 * Integrates SDWebImage async image loading and Firebase Storage with UIImageView.
 *
 * @code
 // Reference to an image file in Firebase Storage
 FIRStorageReference *reference = [storageRef child:@"images/stars.jpg"];
 
 // UIImageView in your ViewController
 UIImageView *imageView = self.imageView;
 
 // Placeholder image
 UIImage *placeholderImage;
 
 // Load the image using SDWebImage
 [imageView sd_setImageWithStorageReference:reference placeholderImage:placeholderImage];
 * @endcode
 */
@interface UIImageView (FirebaseStorage)

/**
 * The current download task, if the image view is downloading an image.
 */
@property (nonatomic, readonly, nullable) FIRStorageDownloadTask *sd_currentDownloadTask;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 */
- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef  A Firebase Storage reference containing an image.
 * @param placeholder An image to display while the download is in progress.
 */
- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                       placeholderImage:(nullable UIImage *)placeholder;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef      A Firebase Storage reference containing an image.
 * @param placeholder     An image to display while the download is in progress.
 * @param completionBlock A closure to handle events when the image finishes downloading.
 *   The closure is guaranteed to be invoked on the main queue.
 */
- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                       placeholderImage:(nullable UIImage *)placeholder
                             completion:(void (^_Nullable)(UIImage *_Nullable,
                                                           NSError *_Nullable,
                                                           SDImageCacheType,
                                                           FIRStorageReference *))completionBlock;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef      A Firebase Storage reference containing an image.
 * @param size            The maximum size of the downloaded image. If the downloaded image
 *   exceeds this size, an error will be raised in the completion block.
 * @param placeholder     An image to display while the download is in progress.
 * @param completionBlock A closure to handle events when the image finishes downloading.
 *   The closure is guaranteed to be invoked on the main queue.
 */
- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                           maxImageSize:(UInt64)size
                       placeholderImage:(nullable UIImage *)placeholder
                             completion:(void (^_Nullable)(UIImage *_Nullable,
                                                           NSError *_Nullable,
                                                           SDImageCacheType,
                                                           FIRStorageReference *))completionBlock;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef      A Firebase Storage reference containing an image.
 * @param size            The maximum size of the downloaded image. If the downloaded image
 *   exceeds this size, an error will be raised in the completion block.
 * @param placeholder     An image to display while the download is in progress.
 * @param options         The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param completionBlock A closure to handle events when the image finishes downloading.
 *   The closure is guaranteed to be invoked on the main queue.
 */
- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                           maxImageSize:(UInt64)size
                       placeholderImage:(nullable UIImage *)placeholder
                                options:(SDWebImageOptions)options
                             completion:(void (^_Nullable)(UIImage *_Nullable,
                                                           NSError *_Nullable,
                                                           SDImageCacheType,
                                                           FIRStorageReference *))completionBlock;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef      A Firebase Storage reference containing an image.
 * @param size            The maximum size of the downloaded image. If the downloaded image
 *   exceeds this size, an error will be raised in the completion block.
 * @param placeholder     An image to display while the download is in progress.
 * @param options         The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param progressBlock   A closure to handle the progress change during the image downloading. The closure args are `receivedSize` `expectedSize` and `storageRef`
 *   The progress block is executed on a background queue.
 * @param completionBlock A closure to handle events when the image finishes downloading.
 *   The closure is guaranteed to be invoked on the main queue.
 */
- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                           maxImageSize:(UInt64)size
                       placeholderImage:(nullable UIImage *)placeholder
                                options:(SDWebImageOptions)options
                               progress:(void (^_Nullable)(NSInteger,
                                                           NSInteger,
                                                           FIRStorageReference *))progressBlock
                             completion:(void (^_Nullable)(UIImage *_Nullable,
                                                           NSError *_Nullable,
                                                           SDImageCacheType,
                                                           FIRStorageReference *))completionBlock;

/**
 * Sets the image view's image to an image downloaded from the Firebase Storage reference.
 * Must be invoked on the main queue.
 *
 * @param storageRef      A Firebase Storage reference containing an image.
 * @param size            The maximum size of the downloaded image. If the downloaded image
 *   exceeds this size, an error will be raised in the completion block.
 * @param placeholder     An image to display while the download is in progress.
 * @param options         The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param context         A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold. For example, you can use [.customManager] to use a custom manager with the desired cache instance for this image request.
 * @param progressBlock   A closure to handle the progress change during the image downloading. The closure args are `receivedSize` `expectedSize` and `storageRef`
 *   The progress block is executed on a background queue.
 * @param completionBlock A closure to handle events when the image finishes downloading.
 *   The closure is guaranteed to be invoked on the main queue.
 */
- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                           maxImageSize:(UInt64)size
                       placeholderImage:(nullable UIImage *)placeholder
                                options:(SDWebImageOptions)options
                                context:(nullable SDWebImageContext *)context
                               progress:(void (^_Nullable)(NSInteger,
                                                           NSInteger,
                                                           FIRStorageReference *))progressBlock
                             completion:(void (^_Nullable)(UIImage *_Nullable,
                                                           NSError *_Nullable,
                                                           SDImageCacheType,
                                                           FIRStorageReference *))completionBlock;

@end

NS_ASSUME_NONNULL_END
