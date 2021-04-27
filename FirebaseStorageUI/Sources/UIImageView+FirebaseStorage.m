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

#import "FirebaseStorageUI/Sources/Public/FirebaseStorageUI/UIImageView+FirebaseStorage.h"
#import "FirebaseStorageUI/Sources/Public/FirebaseStorageUI/FUIStorageImageLoader.h"

@implementation UIImageView (FirebaseStorage)

- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef {
  [self sd_setImageWithStorageReference:storageRef placeholderImage:nil completion:nil];
}

- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                       placeholderImage:(UIImage *)placeholder {
  [self sd_setImageWithStorageReference:storageRef placeholderImage:placeholder completion:nil];
}

- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                       placeholderImage:(UIImage *)placeholder
                             completion:(void (^)(UIImage *_Nullable,
                                                  NSError *_Nullable,
                                                  SDImageCacheType,
                                                  FIRStorageReference *))completionBlock {
  [self sd_setImageWithStorageReference:storageRef
                           maxImageSize:FUIStorageImageLoader.sharedLoader.defaultMaxImageSize
                       placeholderImage:placeholder
                             completion:completionBlock];
}

- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                           maxImageSize:(UInt64)size
                       placeholderImage:(nullable UIImage *)placeholder
                             completion:(void (^)(UIImage *,
                                                  NSError *,
                                                  SDImageCacheType,
                                                  FIRStorageReference *))completionBlock{
  [self sd_setImageWithStorageReference:storageRef
                           maxImageSize:size
                       placeholderImage:placeholder
                                options:0
                             completion:completionBlock];
}

- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                           maxImageSize:(UInt64)size
                       placeholderImage:(nullable UIImage *)placeholder
                                options:(SDWebImageOptions)options
                             completion:(void (^)(UIImage *,
                                                  NSError *,
                                                  SDImageCacheType,
                                                  FIRStorageReference *))completionBlock {
  [self sd_setImageWithStorageReference:storageRef
                           maxImageSize:size
                       placeholderImage:placeholder
                                options:options
                               progress:nil
                             completion:completionBlock];
}

- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                           maxImageSize:(UInt64)size
                       placeholderImage:(nullable UIImage *)placeholder
                                options:(SDWebImageOptions)options
                               progress:(void (^)(NSInteger,
                                                  NSInteger,
                                                  FIRStorageReference *))progressBlock
                             completion:(void (^)(UIImage *,
                                                  NSError *,
                                                  SDImageCacheType,
                                                  FIRStorageReference *))completionBlock {
  [self sd_setImageWithStorageReference:storageRef
                           maxImageSize:size
                       placeholderImage:placeholder
                                options:options
                                context:nil
                               progress:progressBlock
                             completion:completionBlock];
}

- (void)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                           maxImageSize:(UInt64)size
                       placeholderImage:(nullable UIImage *)placeholder
                                options:(SDWebImageOptions)options
                                context:(nullable SDWebImageContext *)context
                               progress:(void (^)(NSInteger,
                                                  NSInteger,
                                                  FIRStorageReference *))progressBlock
                             completion:(void (^)(UIImage *,
                                                  NSError *,
                                                  SDImageCacheType,
                                                  FIRStorageReference *))completionBlock {
  NSParameterAssert(storageRef != nil);
  
  NSURL *url = [NSURL sd_URLWithStorageReference:storageRef];
  
  SDWebImageMutableContext *mutableContext;
  if (context) {
    mutableContext = [context mutableCopy];
  } else {
    mutableContext = [NSMutableDictionary dictionary];
  }
  mutableContext[SDWebImageContextImageLoader] = FUIStorageImageLoader.sharedLoader;
  mutableContext[SDWebImageContextFUIStorageMaxImageSize] = @(size);
  
  [self sd_setImageWithURL:url placeholderImage:placeholder options:options context:[mutableContext copy] progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
    if (progressBlock) {
      progressBlock(receivedSize, expectedSize, storageRef);
    }
  } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    if (completionBlock) {
      completionBlock(image, error, cacheType, storageRef);
    }
  }];
}

#pragma mark - Accessors

- (FIRStorageDownloadTask *)sd_currentDownloadTask {
  SDWebImageCombinedOperation *operation = [self sd_imageLoadOperationForKey:NSStringFromClass(self.class)];
  if (operation) {
    id<SDWebImageOperation> loaderOperation = operation.loaderOperation;
    // This is a protocol, check the class
    if ([loaderOperation isKindOfClass:[FIRStorageDownloadTask class]]) {
      return (FIRStorageDownloadTask *)loaderOperation;
    }
  }
  return nil;
}

@end
