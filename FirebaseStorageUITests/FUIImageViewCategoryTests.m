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

@import XCTest;
@import FirebaseStorageUI;

#import "UIImageView+FirebaseStorage.h"

@class MockDownloadTask, MockStorageReference, MockCache;

@interface MockDownloadTask : NSObject <FUIDownloadTask>
@property (nonatomic, readwrite, getter=isCancelled) BOOL cancelled;
@end

@implementation MockDownloadTask

- (void)cancel {
  self.cancelled = YES;
}

@end


@interface MockCache : NSObject <FUIImageCache>
@property (nonatomic, readonly) NSMutableDictionary *cached;
@end

@implementation MockCache

- (instancetype)init {
  self = [super init];
  if (self != nil) {
    _cached = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key {
  self.cached[key] = image;
}

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key {
  return self.cached[key];
}

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key {
  return self.cached[key];
}

@end


@interface MockStorageReference : NSObject <FUIStorageReference>
@property (nonatomic, readwrite) NSString *fullPath;
@end

@implementation MockStorageReference

- (id<FUIDownloadTask>)dataWithMaxSize:(int64_t)size
                            completion:(void (^)(NSData * _Nullable,
                                                 NSError * _Nullable))completion {
  MockDownloadTask *task = [[MockDownloadTask alloc] init];

  // Fail every download with a max size above 1024 for testing purposes
  if (size > 1024) {
    NSError *error = [NSError errorWithDomain:@"FUITestDownloadErrorDomain"
                                         code:1
                                     userInfo:nil];
    completion(nil, error);
  } else {
    NSData *data = [[NSData alloc] init];
    completion(data, nil);
  }
  return task;
}

@end


@interface FUIImageViewCategoryTests : XCTestCase
@property (nonatomic, readwrite) UIImageView *imageView;
@property (nonatomic, readwrite) MockCache *cache;
@end

@implementation FUIImageViewCategoryTests

- (void)setUp {
  [super setUp];
  self.cache = [[MockCache alloc] init];
  self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testItCreatesADownloadTaskIfCacheIsEmpty {
  MockStorageReference *ref = [[MockStorageReference alloc] init];
  ref.fullPath = @"path/to/image.png";
  id<FUIDownloadTask> download = [self.imageView sd_setImageWithStorageReference:(FIRStorageReference *)ref
                                                                    maxImageSize:512
                                                                placeholderImage:nil
                                                                           cache:self.cache
                                                                      completion:^(UIImage *image,
                                                                                   NSError *error,
                                                                                   SDImageCacheType cacheType,
                                                                                   FIRStorageReference * storageRef) {
    XCTAssert(self.imageView.image == image, @"expected download to populate image");
    XCTAssert(error == nil, @"expected successful download to not produce an error");
  }];
  XCTAssert(download != nil, @"expected image view with empty cache to attempt a download");
}

- (void)testItDoesNotCreateADownloadIfImageIsCached {
  MockStorageReference *ref = [[MockStorageReference alloc] init];
  ref.fullPath = @"path/to/image.png";
  UIImage *image = [[UIImage alloc] init];
  [self.cache storeImage:image forKey:ref.fullPath];
  id<FUIDownloadTask> download = [self.imageView sd_setImageWithStorageReference:(FIRStorageReference *)ref
                                                                    maxImageSize:4096
                                                                placeholderImage:nil
                                                                           cache:self.cache
                                                                      completion:nil];
  XCTAssert(download == nil, @"expected image view to not create new download when fetching cached image");
  XCTAssert(self.imageView.image == image, @"expected image view to use cached image");
}

- (void)testItRaisesAnErrorIfDownloadingFails {
  MockStorageReference *ref = [[MockStorageReference alloc] init];
  ref.fullPath = @"path/to/image.png";
  [self.imageView sd_setImageWithStorageReference:(FIRStorageReference *)ref
                                     maxImageSize:512
                                 placeholderImage:nil
                                            cache:self.cache
                                       completion:^(UIImage *image,
                                                    NSError *error,
                                                    SDImageCacheType cacheType,
                                                    id<FUIStorageReference> storageRef) {
    XCTAssert(image == nil, @"expected failed download to not return an image");
    XCTAssert(self.imageView.image == nil, @"expected failed download to not populate image");
    XCTAssert(error != nil, @"expected failed download to produce an error");
  }];
}

- (void)testItSetsAPlaceholder {
  MockStorageReference *ref = [[MockStorageReference alloc] init];
  ref.fullPath = @"path/to/image.png";
  UIImage *placeholder = [[UIImage alloc] init];
  [self.imageView sd_setImageWithStorageReference:(FIRStorageReference *)ref
                                     maxImageSize:4096
                                 placeholderImage:placeholder
                                            cache:self.cache
                                       completion:nil];
  XCTAssert(self.imageView.image == placeholder, @"expected image view to use placeholder on failed download");
}

- (void)testItCancelsTheCurrentDownloadWhenSettingAnImage {
  MockStorageReference *ref = [[MockStorageReference alloc] init];
  ref.fullPath = @"path/to/image.png";
  MockDownloadTask *download = [self.imageView sd_setImageWithStorageReference:(FIRStorageReference *)ref
                                                                  maxImageSize:512
                                                              placeholderImage:nil
                                                                         cache:self.cache
                                                                    completion:nil];
  ref = [[MockStorageReference alloc] init];
  [self.imageView sd_setImageWithStorageReference:(FIRStorageReference *)ref
                                     maxImageSize:512
                                 placeholderImage:nil
                                            cache:self.cache
                                       completion:nil];

  XCTAssert(download.isCancelled == YES, @"expected setting a new image on an imageview to cancel the old download");
}

- (void)testItDoesntHaveARaceCondition /* hahahaha! you have no power here... */ {

}

@end
