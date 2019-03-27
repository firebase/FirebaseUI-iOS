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

#import "SDWebImageFirebaseLoader.h"
#import "NSURL+SDWebImageFirebaseLoader.h"
#import "SDWebImageFirebaseLoaderDefine.h"

@implementation SDWebImageFirebaseLoader

+ (SDWebImageFirebaseLoader *)sharedLoader {
    static dispatch_once_t onceToken;
    static SDWebImageFirebaseLoader *loader;
    dispatch_once(&onceToken, ^{
        loader = [[SDWebImageFirebaseLoader alloc] init];
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

#pragma mark - SDImageLoader
- (BOOL)canLoadWithURL:(NSURL *)url {
    return url.sd_storageReference;
}

- (id<SDWebImageOperation>)loadImageWithURL:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDImageLoaderCompletedBlock)completedBlock {
    FIRStorageReference *storageRef = url.sd_storageReference;
    if (!storageRef) {
        return nil;
    }
    
    UInt64 size;
    if (context[SDWebImageContextFirebaseMaxImageSize]) {
        size = [context[SDWebImageContextFirebaseMaxImageSize] unsignedLongLongValue];
    } else {
        size = self.defaultMaxImageSize;
    }
    // Download the image from Firebase Storage
    
    // TODO, is there any progressive download API for Firebase Storage ? Found `FIRStorageTaskStatusProgress` and `GTMSessionFetcher`
    // Seems we can support the progressive decoding of SDWebImage using custom loader.
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
    
    return download;
}

@end
