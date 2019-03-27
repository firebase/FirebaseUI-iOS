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

#import "UIImageView+FirebaseStorage.h"
#import "SDWebImageFirebaseLoader.h"

@implementation UIImageView (FirebaseStorage)

+ (UInt64)sd_defaultMaxImageSize {
    // TODO, remove this totally ? I guess the FirebaseUI need a version bump
    return SDWebImageFirebaseLoader.sharedLoader.defaultMaxImageSize;
}

+ (void)sd_setDefaultMaxImageSize:(UInt64)size {
    // TODO, remove this totally ? I guess the FirebaseUI need a version bump
    SDWebImageFirebaseLoader.sharedLoader.defaultMaxImageSize = size;
}

- (FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef {
    return [self sd_setImageWithStorageReference:storageRef placeholderImage:nil completion:nil];
}

- (FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                           placeholderImage:(UIImage *)placeholder {
    return [self sd_setImageWithStorageReference:storageRef placeholderImage:placeholder completion:nil];
}

- (FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                           placeholderImage:(UIImage *)placeholder
                                                 completion:(void (^)(UIImage *_Nullable,
                                                                      NSError *_Nullable,
                                                                      SDImageCacheType,
                                                                      FIRStorageReference *))completion {
    return [self sd_setImageWithStorageReference:storageRef
                                    maxImageSize:SDWebImageFirebaseLoader.sharedLoader.defaultMaxImageSize
                                placeholderImage:placeholder
                                      completion:completion];
}

- (FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                               maxImageSize:(UInt64)size
                                           placeholderImage:(nullable UIImage *)placeholder
                                                 completion:(void (^)(UIImage *,
                                                                      NSError *,
                                                                      SDImageCacheType,
                                                                      FIRStorageReference *))completion{
  return [self sd_setImageWithStorageReference:storageRef
                                  maxImageSize:size
                              placeholderImage:placeholder
                                         cache:[SDImageCache sharedImageCache]
                                    completion:completion];
}

- (FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                               maxImageSize:(UInt64)size
                                           placeholderImage:(nullable UIImage *)placeholder
                                                      cache:(nullable SDImageCache *)cache
                                                 completion:(void (^)(UIImage *,
                                                                      NSError *,
                                                                      SDImageCacheType,
                                                                      FIRStorageReference *))completion {
    return [self sd_setImageWithStorageReference:storageRef
                                    maxImageSize:size
                                placeholderImage:placeholder
                                           cache:cache
                                        progress:nil
                                      completion:completion];
}

- (FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                               maxImageSize:(UInt64)size
                                           placeholderImage:(nullable UIImage *)placeholder
                                                      cache:(nullable SDImageCache *)cache
                                                   progress:(void (^)(NSInteger,
                                                                      NSInteger,
                                                                      FIRStorageReference *))progressBlock
                                                 completion:(void (^)(UIImage *,
                                                                      NSError *,
                                                                      SDImageCacheType,
                                                                      FIRStorageReference *))completion {
    NSParameterAssert(storageRef != nil);
    
    NSURL *url = [NSURL sd_URLWithStorageReference:storageRef];
    
    SDWebImageManager *manager = [[SDWebImageManager alloc] initWithCache:cache loader:SDWebImageFirebaseLoader.sharedLoader];
    
    // TODO: A little strange, Firebase Storage API don't apply cache until user provide a cache instance ? Check later
    SDWebImageOptions options = 0;
    if (!cache) {
        options |= SDWebImageFromLoaderOnly;
    }
    // TODO: Current version use `fullpath` as cache key, but not the URL. Do we need to keep compabitle ?
    SDWebImageCacheKeyFilter *cacheKeyFilter = [SDWebImageCacheKeyFilter cacheKeyFilterWithBlock:^NSString * _Nullable(NSURL * _Nonnull url) {
        FIRStorageReference *ref = url.sd_storageReference;
        if (ref) {
            return ref.fullPath;
        } else {
            return url.absoluteString;
        }
    }];
    SDWebImageContext *context = @{
                                   SDWebImageContextFirebaseMaxImageSize : @(size),
                                   SDWebImageContextCustomManager : manager,
                                   SDWebImageContextCacheKeyFilter : cacheKeyFilter
                                   };
    
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options context:context progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (progressBlock) {
            progressBlock(receivedSize, expectedSize, storageRef);
        }
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (completion) {
            completion(image, error, cacheType, storageRef);
        }
    }];
    
    // TODO, the return value should be void.
    // Because `sd_setImageWithURL` is asynchonizelly, it need to query disk cache before network request (Firebase download). So by the time the function return, this should be nil;
    // Previous implementation, query the disk cache and even decoding on the main queue (!), it's not a good idea which blocking the UI.
    return nil;
}

#pragma mark - Getter
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
