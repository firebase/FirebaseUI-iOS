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

#import "FirebaseStorageUI/Sources/Public/FirebaseStorageUI/NSURL+FirebaseStorage.h"
#import <objc/runtime.h>

@implementation NSURL (FirebaseStorage)

- (FIRStorageReference *)sd_storageReference {
  return objc_getAssociatedObject(self, @selector(sd_storageReference));
}

- (void)setSd_storageReference:(FIRStorageReference * _Nullable)sd_storageReference {
  objc_setAssociatedObject(self, @selector(sd_storageReference), sd_storageReference, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (instancetype)sd_URLWithStorageReference:(FIRStorageReference *)storageRef {
  if (!storageRef.bucket || !storageRef.fullPath) {
    return nil;
  }
  // gs://bucket/path/to/object.txt
  NSURLComponents *components = [[NSURLComponents alloc] initWithString:[NSString stringWithFormat:@"%@://%@/", @"gs", storageRef.bucket]];
  NSString *encodedPath = [storageRef.fullPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
  components.path = [components.path stringByAppendingString:encodedPath];
  
  NSURL *url = components.URL;
  if (!url) {
    return nil;
  }
  
  url.sd_storageReference = storageRef;
  
  return url;
}

@end
