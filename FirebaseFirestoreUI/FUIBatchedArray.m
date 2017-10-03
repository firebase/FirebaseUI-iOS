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

@property (nonatomic, readwrite, copy) NSArray<FIRDocumentSnapshot *> *items;
@property (nonatomic, readwrite) id<FIRListenerRegistration> observer;

/// A private member used to keep track of whether or not the current array
/// contents are in sync with the query. If the query changes we cannot use
/// the FIRDocumentChanges provided with the next update to produce a diff,
/// so we need to keep track of it somehow.
@property (nonatomic, readwrite) BOOL isInSync;

@end

@implementation FUIBatchedArray

- (instancetype)initWithQuery:(FIRQuery *)query delegate:(id<FUIBatchedArrayDelegate>)delegate {
  self = [super init];
  if (self != nil) {
    _delegate = delegate;
    _query = query;
    _items = @[];

    // Firestore sends initial data as insertions, so this can be YES on init.
    _isInSync = YES;
  }
  return self;
}

- (void)observeQuery {
  if (self.observer != nil) { return; }
  // Since self retains the query, the query's block shouldn't retain self.
  __weak typeof(self) weakSelf = self;

  self.observer = [self.query addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
    __strong typeof(weakSelf) sself = weakSelf;
    if (sself == nil) { return; }
    if (error != nil) {
      NSLog(@"Firestore error: %@", error);

      if ([sself.delegate respondsToSelector:@selector(batchedArray:queryDidFailWithError:)]) {
        [sself.delegate batchedArray:sself queryDidFailWithError:error];
      }
    }

    FUISnapshotArrayDiff *diff;

    if (sself.isInSync) {
      diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:sself.items
                                                    resultArray:snapshot.documents
                                                documentChanges:snapshot.documentChanges];
    } else {
      diff = [[FUISnapshotArrayDiff alloc] initWithInitialArray:sself.items
                                                    resultArray:snapshot.documents];
    }

    sself.items = snapshot.documents;
    sself.isInSync = YES;

    if ([sself.delegate respondsToSelector:@selector(batchedArray:didUpdateWithDiff:)]) {
      [sself.delegate batchedArray:sself didUpdateWithDiff:diff];
    }
  }];
}

- (void)stopObserving {
  if (self.observer == nil) { return; }
  [self.observer remove];
  self.observer = nil;
  self.isInSync = NO;
}

- (void)setQuery:(FIRQuery *)query {
  self.isInSync = NO;
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

- (FIRDocumentSnapshot *)objectAtIndex:(NSInteger)index {
  return self.items[index];
}

- (FIRDocumentSnapshot *)objectAtIndexedSubscript:(NSInteger)index {
  return [self objectAtIndex:index];
}

- (void)dealloc {
  [self stopObserving];
}

@end

@interface FIRDocumentSnapshot (FirebaseUI) <NSCopying>
@end

@implementation FIRDocumentSnapshot (FirebaseUI)

- (NSUInteger)hash {
  return self.documentID.hash;
}

- (BOOL)isEqual:(FIRDocumentSnapshot *)object {
  if (![object isKindOfClass:[FIRDocumentSnapshot class]]) {
    return NO;
  }

  return [object.documentID isEqual:self.documentID];
}

- (instancetype)copyWithZone:(NSZone *)zone {
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, id: %@>",
      NSStringFromClass([self class]), self, self.documentID];
}

@end

@interface FIRDocumentChange (FirebaseUI)
@end

@implementation FIRDocumentChange (FirebaseUI)

- (NSString *)description {
  NSString *changeType;
  switch (self.type) {
    case FIRDocumentChangeTypeAdded:
      changeType = @"Add";
      break;
    case FIRDocumentChangeTypeRemoved:
      changeType = @"Delete";
      break;
    case FIRDocumentChangeTypeModified:
      changeType = @"Change";
      break;
  }

  return [NSString stringWithFormat:@"<%@: %p, %@: %lu -> %lu>",
      NSStringFromClass([self class]), self, changeType,
          (unsigned long)self.oldIndex, (unsigned long)self.newIndex];
}

@end
