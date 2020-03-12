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
#import <GTMSessionFetcher/GTMSessionFetcher.h>

@interface NSURL ()

@property (nonatomic, strong, readwrite, nullable) FIRStorageReference *sd_storageReference;

@end

@interface FIRStorageTask ()

@property(strong, atomic) GTMSessionFetcher *fetcher;

@end

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
    _defaultMaxImageSize = 10e6;
  }
  return self;
}

#pragma mark - SDImageLoader Protocol

- (BOOL)canRequestImageForURL:(NSURL *)url {
  if (!url) {
    return NO;
  }
  if ([url.scheme isEqualToString:@"gs"]) {
    return YES;
  }
  return url.sd_storageReference != nil;
}

- (id<SDWebImageOperation>)requestImageWithURL:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDImageLoaderCompletedBlock)completedBlock {
  FIRStorageReference *storageRef = url.sd_storageReference;
  if (!storageRef) {
    // Create Storage Reference from URL
    NSString *bucketUrl = [NSString stringWithFormat:@"gs://%@", url.host];
    FIRStorage *storage = [FIRStorage storageWithURL:bucketUrl];
    storageRef = [storage referenceWithPath:url.path];
    url.sd_storageReference = storageRef;
  }
  
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
  // Each download task use independent serial coder queue, to ensure callback in order during prorgessive decoding
  NSOperationQueue *coderQueue = [NSOperationQueue new];
  coderQueue.maxConcurrentOperationCount = 1;
  FIRStorageDownloadTask * download = [storageRef dataWithMaxSize:size completion:^(NSData * _Nullable data, NSError * _Nullable error) {
    if (error) {
      dispatch_main_async_safe(^{
        if (completedBlock) {
          completedBlock(nil, nil, error, YES);
        }
      });
      return;
    }
    // Decode the image with data
    [coderQueue cancelAllOperations];
    [coderQueue addOperationWithBlock:^{
      UIImage *image = SDImageLoaderDecodeImageData(data, url, options, context);
      dispatch_main_async_safe(^{
        if (completedBlock) {
          completedBlock(image, data, nil, YES);
        }
      });
    }];
  }];
  // Observe the progress changes
  [download observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
    // Check progressive decoding if need
    if (options & SDWebImageProgressiveLoad) {
      FIRStorageDownloadTask *task = snapshot.task;
      // Currently, FIRStorageDownloadTask does not have the API to grab partial data
      // But since FirebaseUI and Firebase are seamless component, we access the internal fetcher here
      GTMSessionFetcher *fetcher = task.fetcher;
      // Get the partial image data
      NSData *partialData = [fetcher.downloadedData copy];
      // Get response
      int64_t expectedSize = fetcher.response.expectedContentLength;
      expectedSize = expectedSize > 0 ? expectedSize : 0;
      int64_t receivedSize = fetcher.downloadedLength;
      if (expectedSize != 0) {
        // Get the finish status
        BOOL finished = receivedSize >= expectedSize;
        // This progress block may be called on main queue or global queue (depends configuration), always dispatched on coder queue
        if (coderQueue.operationCount == 0) {
          [coderQueue addOperationWithBlock:^{
            UIImage *image = SDImageLoaderDecodeProgressiveImageData(partialData, url, finished, task, options, context);
            if (image) {
              dispatch_main_async_safe(^{
                if (completedBlock) {
                  completedBlock(image, partialData, nil, NO);
                }
              });
            }
          }];
        }
      }
    }
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
