// clang-format off

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

// clang-format on

#import "FUIDataSource.h"

@interface FUIDataSource ()

@property(copy, nonatomic, nonnull) void (^cancelBlock)(NSError *);

/**
 * The FirebaseArray which backs the instance of the datasource.
 */
@property(strong, nonatomic, nonnull) id<FUICollection> collection;

@end

@implementation FUIDataSource

#pragma mark - Initializer methods

- (instancetype)initWithCollection:(id<FUICollection>)collection {
  self = [super init];
  if (self) {
    _collection = collection;
    _collection.delegate = self;
    [_collection observeQuery];
  }
  return self;
}

#pragma mark - API methods

- (NSArray *)items {
  return [self.collection.items copy];
}

- (NSUInteger)count {
  return self.collection.count;
}

- (FIRDataSnapshot *)objectAtIndex:(NSUInteger)index {
  return [self.collection snapshotAtIndex:index];
}

- (void)cancelWithBlock:(void (^)(NSError *))block {
  self.cancelBlock = block;
}

#pragma mark - FUICollectionDelegate methods

- (void)canceledWithError:(NSError *)error {
  if (self.cancelBlock != nil) {
    self.cancelBlock(error);
  }
}

@end
