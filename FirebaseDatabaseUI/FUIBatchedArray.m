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

#import "FUIBatchedArray.h"

@interface FUIBatchedArray ()

@property (nonatomic, readwrite) NSArray<FIRDataSnapshot *> *items;
@property (nonatomic, readwrite) NSNumber *observer;

@end

@implementation FUIBatchedArray

- (instancetype)initWithQuery:(id<FUIDataObservable>)query delegate:(id<FUIBatchedArrayDelegate>)delegate {
  self = [super init];
  if (self != nil) {
    _delegate = delegate;
    _query = query;
    _items = @[];
  }
  return self;
}

- (void)observeQuery {
  if (self.observer != nil) { return; }
  // Since self retains the query, the query shouldn't also retain the block that retains self.
  __weak typeof(self) weakSelf = self;
  FIRDatabaseHandle obs = [self.query observeEventType:FIRDataEventTypeValue
                        andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot * _Nonnull snapshot,
                                                         NSString * _Nullable prevKey) {
      NSCAssert([snapshot.value isKindOfClass:[NSArray class]],
                @"Expected snapshot's value to be a collection, but instead got %@", snapshot.value);
      FUISnapshotArrayDiff *diff =
          [[FUISnapshotArrayDiff alloc] initWithInitialArray:weakSelf.items
                                                 resultArray:snapshot.value];
      weakSelf.items = snapshot.value;
      if ([weakSelf.delegate respondsToSelector:@selector(batchedArray:didUpdateWithDiff:)]) {
        [weakSelf.delegate batchedArray:weakSelf didUpdateWithDiff:diff];
      }
  } withCancelBlock:^(NSError * _Nonnull error) {
    if ([weakSelf.delegate respondsToSelector:@selector(batchedArray:queryDidFailWithError:)]) {
      [weakSelf.delegate batchedArray:self queryDidFailWithError:error];
    }
  }];
  self.observer = @(obs);
}

- (void)stopObserving {
  if (self.observer == nil) { return; }
  [self.query removeObserverWithHandle:self.observer.unsignedIntegerValue];
}

- (void)setQuery:(id<FUIDataObservable>)query {
  BOOL wasObserving = self.observer != nil;
  [self stopObserving];
  _query = query;
  if (wasObserving) {
    [self observeQuery];
  }
}

- (NSInteger)count {
  return self.items.count;
}

- (FIRDataSnapshot *)objectAtIndex:(NSInteger)index {
  return self.items[index];
}

- (FIRDataSnapshot *)objectAtIndexedSubscript:(NSInteger)index {
  return [self objectAtIndex:index];
}

- (void)dealloc {
  [self stopObserving];
}

@end

@interface FIRDataSnapshot (FirebaseUI)
@end

@implementation FIRDataSnapshot (FirebaseUI)

- (BOOL)isEqual:(FIRDataSnapshot *)object {
  if (![object isKindOfClass:[FIRDataSnapshot class]]) {
    return NO;
  }

  return [object.key isEqual:self.key] && [object.value isEqual:self.value];
}

@end
