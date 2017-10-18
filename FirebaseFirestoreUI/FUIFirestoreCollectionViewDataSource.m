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

#import "FUIFirestoreCollectionViewDataSource.h"

@interface FUIFirestoreCollectionViewDataSource () <FUIBatchedArrayDelegate>

@property (nonatomic, readonly, nonnull) FUIBatchedArray *collection;

/**
 * The callback to populate a subclass of UICollectionViewCell with an object
 * provided by the datasource.
 */
@property (copy, nonatomic, readonly) UICollectionViewCell *(^populateCellAtIndexPath)
  (UICollectionView *collectionView, NSIndexPath *indexPath, FIRDocumentSnapshot *object);

@end

@implementation FUIFirestoreCollectionViewDataSource

#pragma mark - FUIDataSource initializer methods

- (instancetype)initWithCollection:(FUIBatchedArray *)collection
                      populateCell:(UICollectionViewCell * (^)(UICollectionView *,
                                                               NSIndexPath *,
                                                               FIRDocumentSnapshot *))populateCell {
  self = [super init];
  if (self) {
    _collection = collection;
    _collection.delegate = self;
    _populateCellAtIndexPath = populateCell;
  }
  return self;
}

- (instancetype)initWithQuery:(FIRQuery *)query
                 populateCell:(UICollectionViewCell *(^)(UICollectionView *,
                                                         NSIndexPath *,
                                                         FIRDocumentSnapshot *))populateCell {
  FUIBatchedArray *array = [[FUIBatchedArray alloc] initWithQuery:query delegate:self];
  return [self initWithCollection:array populateCell:populateCell];
}

- (NSUInteger)count {
  return self.collection.count;
}

- (NSArray<FIRDocumentSnapshot *> *)items {
  return self.collection.items;
}

- (FIRDocumentSnapshot *)snapshotAtIndex:(NSInteger)index {
  return self.collection[index];
}

- (void)bindToView:(UICollectionView *)view {
  self.collectionView = view;
  view.dataSource = self;
  [self.collection observeQuery];
}

- (void)unbind {
  self.collectionView.dataSource = nil;
  self.collectionView = nil;
  [self.collection stopObserving];
}

- (FIRQuery *)query {
  return self.collection.query;
}

- (void)setQuery:(FIRQuery *)query {
  self.collection.query = query;
}

#pragma mark - FUIBatchedArrayDelegate methods

- (void)batchedArray:(FUIBatchedArray *)array
   didUpdateWithDiff:(FUISnapshotArrayDiff<FIRDocumentSnapshot *> *)diff {
  [self.collectionView performBatchUpdates:^{

    NSMutableArray *deletedIndexPaths =
        [NSMutableArray arrayWithCapacity:diff.deletedIndexes.count];
    for (NSNumber *deletedIndex in diff.deletedIndexes) {
      NSIndexPath *deleted = [NSIndexPath indexPathForItem:deletedIndex.integerValue inSection:0];
      [deletedIndexPaths addObject:deleted];
    }
    [self.collectionView deleteItemsAtIndexPaths:deletedIndexPaths];

    NSMutableArray *changedIndexPaths =
        [NSMutableArray arrayWithCapacity:diff.changedIndexes.count];
    for (NSNumber *changedIndex in diff.changedIndexes) {
      NSIndexPath *changed = [NSIndexPath indexPathForItem:changedIndex.integerValue inSection:0];
      [changedIndexPaths addObject:changed];
    }
    // Use a delete and insert instead of a reload. See
    // https://stackoverflow.com/questions/42147822/uicollectionview-batchupdate-edge-case-fails
    [self.collectionView deleteItemsAtIndexPaths:changedIndexPaths];
    [self.collectionView insertItemsAtIndexPaths:changedIndexPaths];

    for (NSInteger i = 0; i < diff.movedInitialIndexes.count; i++) {
      NSInteger initialIndex = diff.movedInitialIndexes[i].integerValue;
      NSInteger finalIndex   = diff.movedResultIndexes[i].integerValue;
      NSIndexPath *initialPath = [NSIndexPath indexPathForItem:initialIndex inSection:0];
      NSIndexPath *finalPath   = [NSIndexPath indexPathForItem:finalIndex inSection:0];

      [self.collectionView moveItemAtIndexPath:initialPath toIndexPath:finalPath];
    }

    NSMutableArray *insertedIndexPaths =
        [NSMutableArray arrayWithCapacity:diff.insertedIndexes.count];
    for (NSNumber *insertedIndex in diff.insertedIndexes) {
      NSIndexPath *inserted = [NSIndexPath indexPathForItem:insertedIndex.integerValue inSection:0];
      [insertedIndexPaths addObject:inserted];
    }
    [self.collectionView insertItemsAtIndexPaths:insertedIndexPaths];

  } completion:^(BOOL finished) {
    NSLog(@"Updated with diff: %@", diff);
    NSLog(@"Total: %ld", (long)_collection.count);
  }];
}

- (void)batchedArray:(FUIBatchedArray *)array queryDidFailWithError:(NSError *)error {
  if (self.queryErrorHandler != nil) {
    self.queryErrorHandler(error);
  } else {
    NSLog(@"%@ Unhandled Firestore error: %@", self, error);
  }
}

#pragma mark - UICollectionViewDataSource methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                          cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
  FIRDocumentSnapshot *snap = [self.collection.items objectAtIndex:indexPath.item];

  UICollectionViewCell *cell = self.populateCellAtIndexPath(collectionView, indexPath, snap);

  return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(nonnull UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.collection.count;
}

@end

@implementation UICollectionView (FUIFirestoreCollectionViewDataSource)

- (FUIFirestoreCollectionViewDataSource *)bindToFirestoreQuery:(FIRQuery *)query
    populateCell:(UICollectionViewCell *(^)(UICollectionView *,
                                            NSIndexPath *,
                                            FIRDocumentSnapshot *))populateCell {
  FUIFirestoreCollectionViewDataSource *dataSource =
      [[FUIFirestoreCollectionViewDataSource alloc] initWithQuery:query populateCell:populateCell];
  [dataSource bindToView:self];
  return dataSource;
}

@end
