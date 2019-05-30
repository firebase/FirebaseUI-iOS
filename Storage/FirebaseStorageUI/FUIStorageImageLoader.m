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

#import "FUIStorageImageLoader.h"
#import "FIRStorageDownloadTask+SDWebImage.h"
#import <FirebaseCore/FirebaseCore.h>

@implementation FUIStorageImageLoader

+ (FUIStorageImageLoader *)sharedLoader {
  static dispatch_once_t onceToken;
  static FUIStorageImageLoader *loader;
  dispatch_once(&onceToken, ^{
    loader = [[FUIStorageImageLoader alloc] init];
  });
  return loader;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.defaultMaxImageSize = 10e6;
  }
  return self;
}

#pragma mark - SDImageLoader Protocol

- (BOOL)canRequestImageForURL:(NSURL *)url {
  return url.sd_storageReference != nil;
}

- (id<SDWebImageOperation>)requestImageWithURL:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDImageLoaderCompletedBlock)completedBlock {
  FIRStorageReference *storageRef = url.sd_storageReference;
  if (!storageRef) {
    if (completedBlock) {
      NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"The provided image url must have an associated FIRStorageReference."}];
      completedBlock(nil, nil, error, YES);
    }
  }
  
  UInt64 size;
  if (context[SDWebImageContextFUIStorageMaxImageSize]) {
    size = [context[SDWebImageContextFUIStorageMaxImageSize] unsignedLongLongValue];
  } else {
    size = self.defaultMaxImageSize;
  }
  // Download the image from Firebase Storage
  
  // TODO: Support progressive image loading using the `GTMSessionFetcher.downloadedData` with `SDImageLoaderDecodeProgressiveImageData`
  FIRStorageDownloadTask * download = [storageRef dataWithMaxSize:size
                                                       completion:^(NSData * _Nullable data, NSError * _Nullable error) {
                                                         if (error) {
                                                           dispatch_main_async_safe(^{
                                                             if (completedBlock) {
                                                               completedBlock(nil, nil, error, YES);
                                                             }
                                                           });
                                                           return;
                                                         }
                                                         // Decode the image with data
                                                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                                           UIImage *image = SDImageLoaderDecodeImageData(data, url, options, context);
                                                           dispatch_main_async_safe(^{
                                                             if (completedBlock) {
                                                               completedBlock(image, data, nil, YES);
                                                             }
                                                           });
                                                         });
                                                       }];
  // Observe the progress changes
  [download observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
    NSProgress *progress = snapshot.progress;
    if (progressBlock) {
      progressBlock((NSInteger)progress.completedUnitCount,
                    (NSInteger)progress.totalUnitCount,
                    url);
    }
  }];
  
  return download;
}

- (BOOL)shouldBlockFailedURLWithURL:(NSURL *)url error:(NSError *)error {
  if ([error.domain isEqualToString:FIRStorageErrorDomain]) {
    if (error.code == FIRStorageErrorCodeBucketNotFound
        || error.code == FIRStorageErrorCodeProjectNotFound
        || error.code == FIRStorageErrorCodeObjectNotFound) {
      return YES;
    }
  }
  return NO;
}

@end
