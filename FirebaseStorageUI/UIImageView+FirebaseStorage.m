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

#import <objc/runtime.h>

#import "UIImageView+FirebaseStorage.h"

@interface UIImageView (FirebaseStorage_Private)
@property (nonatomic, readwrite, nullable) FIRStorageDownloadTask *currentDownload;
@end

@implementation UIImageView (FirebaseStorage)

- (FIRStorageDownloadTask *)fui_setImageWithStorageReference:(FIRStorageReference *)storageRef {
  return [self fui_setImageWithStorageReference:storageRef placeholderImage:nil completion:nil];
}

- (FIRStorageDownloadTask *)fui_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                            placeholderImage:(UIImage *)placeholder {
  return [self fui_setImageWithStorageReference:storageRef placeholderImage:placeholder completion:nil];
}

- (FIRStorageDownloadTask *)fui_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                            placeholderImage:(UIImage *)placeholder
                                                  completion:(void (^)(UIImage * _Nullable,
                                                                       NSError * _Nullable,
                                                                       SDImageCacheType,
                                                                       FIRStorageReference * _Nonnull))completion {
  return [self fui_setImageWithStorageReference:storageRef
                                   maxImageSize:5e6 // 5 megabytes
                               placeholderImage:placeholder
                                     completion:completion];
}

- (FIRStorageDownloadTask *)fui_setImageWithStorageReference:(FIRStorageReference *)storageRef
                                                maxImageSize:(UInt64)size
                                            placeholderImage:(nullable UIImage *)placeholder
                                                  completion:(void (^)(UIImage *,
                                                                       NSError *,
                                                                       SDImageCacheType,
                                                                       FIRStorageReference *))completion {
  NSParameterAssert(storageRef != nil);
  self.image = placeholder;

  // If there's already a download on this UIImageView, cancel it
  if (self.currentDownload != nil) {
    [self.currentDownload cancel];
    self.currentDownload = nil;
  }

  // Query cache for image before trying to download
  SDImageCache *cache = [SDImageCache sharedImageCache];
  NSString *key = storageRef.fullPath;
  UIImage *cached = nil;

  cached = [cache imageFromMemoryCacheForKey:key];
  if (cached != nil) {
    self.image = cached;
    if (completion != nil) {
      completion(cached, nil, SDImageCacheTypeMemory, storageRef);
    }
    return nil;
  }

  cached = [cache imageFromDiskCacheForKey:key];
  if (cached != nil) {
    self.image = cached;
    if (completion != nil) {
      completion(cached, nil, SDImageCacheTypeDisk, storageRef);
    }
    return nil;
  }

  // If nothing was found in cache, download the image from Firebase Storage
  FIRStorageDownloadTask *download = [storageRef dataWithMaxSize:size
                                                      completion:^(NSData * _Nullable data,
                                                                   NSError * _Nullable error) {
    self.currentDownload = nil;
    if (data != nil) {
      dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageWithData:data];
        self.image = image;

        // Cache downloaded image
        [cache storeImage:image forKey:storageRef.fullPath];

        if (completion != nil) {
          completion(image, nil, SDImageCacheTypeNone, storageRef);
        }
      });
    } else {
      if (completion != nil) {
        completion(nil, error, SDImageCacheTypeNone, storageRef);
      }
    }
  }];
  self.currentDownload = download;
  return download;
}

#pragma mark - Accessors

- (void)setCurrentDownload:(FIRStorageDownloadTask *)currentDownload {
  objc_setAssociatedObject(self,
                           @selector(currentDownload),
                           currentDownload,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FIRStorageDownloadTask *)currentDownload {
  return objc_getAssociatedObject(self, @selector(currentDownload));
}

@end
