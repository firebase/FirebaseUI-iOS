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

#import "FLAnimatedImageView+FirebaseStorage.h"

@interface FLAnimatedImageView ()
@property (readwrite) FIRStorageDownloadTask *sd_currentDownloadTask;
@end

@implementation FLAnimatedImageView (FirebaseStorage)

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
                                  maxImageSize:[UIImageView sd_defaultMaxImageSize]
                              placeholderImage:placeholder
                                    completion:completion];
}

- (FIRStorageDownloadTask *)sd_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                               maxImageSize:(UInt64)size
                                           placeholderImage:(nullable UIImage *)placeholder
                                                 completion:(void (^)(UIImage *,
                                                                      NSError *,
                                                                      SDImageCacheType,
                                                                      FIRStorageReference *))completion {
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
  NSParameterAssert(storageRef != nil);

  // If there's already a download on this UIImageView, cancel it
  if (self.sd_currentDownloadTask != nil) {
    [self.sd_currentDownloadTask cancel];
    self.sd_currentDownloadTask = nil;
  }

  // Set placeholder image
  self.image = placeholder;

  // Query cache for image before trying to download
  NSString *key = storageRef.fullPath;

  [cache queryCacheOperationForKey:key done:^(UIImage * _Nullable image,
                                              NSData * _Nullable data,
                                              SDImageCacheType cacheType) {
    if (data != nil) {
      SDImageFormat format = [NSData sd_imageFormatForImageData:data];
      if (format == SDImageFormatGIF) {
        FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
        self.animatedImage = image;
        self.image = nil;
      } else {
        UIImage *image = [UIImage imageWithData:data];
        self.image = image;
        self.animatedImage = nil;
      }
    }

    // If nothing was found in cache, download the image from Firebase Storage
    FIRStorageDownloadTask *download = [storageRef dataWithMaxSize:size
                                                        completion:^(NSData *_Nullable data,
                                                                     NSError *_Nullable error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (data != nil) {
          UIImage *image;

          SDImageFormat format = [NSData sd_imageFormatForImageData:data];
          if (format == SDImageFormatGIF) {
            FLAnimatedImage *animated = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
            self.animatedImage = animated;
            self.image = nil;
          } else {
            image = [UIImage imageWithData:data];
            self.image = image;
            self.animatedImage = nil;
          }

          // Cache downloaded image
          [cache storeImage:image imageData:data forKey:key toDisk:YES completion:^{}];
          
          if (completion != nil) {
            completion(image, nil, SDImageCacheTypeNone, storageRef);
          }
        } else {
          if (completion != nil) {
            completion(nil, error, SDImageCacheTypeNone, storageRef);
          }
        }
      });
    }];
    self.sd_currentDownloadTask = download;
  }];
  return nil;
}

@end
