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

#import "FirebaseDatabaseUI/Sources/Public/FirebaseDatabaseUI/FUICollectionViewDataSource.h"
#import "FirebaseDatabaseUI/Sources/Public/FirebaseDatabaseUI/FUIArray.h"

@interface FUICollectionViewDataSource () <FUICollectionDelegate>

@property (nonatomic, readonly, nonnull) id<FUICollection> collection;

/**
 * Count is tracked separately from the FUIArray to make sure
 * count isn't invalid during an animated update.
 */
@property (nonatomic, readwrite, assign) NSUInteger count;

/**
 * The callback to populate a subclass of UICollectionViewCell with an object
 * provided by the datasource.
 */
@property (strong, nonatomic, readonly) UICollectionViewCell *(^populateCellAtIndexPath)
  (UICollectionView *collectionView, NSIndexPath *indexPath, FIRDataSnapshot *object);

@property (nonatomic, strong) NSMutableArray<void (^)(dispatch_block_t)> *pendingUpdates;

@property (nonatomic, assign) BOOL isApplyingBatchUpdate;

@property (nonatomic, strong) NSMutableArray<FIRDataSnapshot *> *displayedSnapshots;

@end

@implementation FUICollectionViewDataSource

#pragma mark - FUIDataSource initializer methods

- (instancetype)initWithCollection:(id<FUICollection>)collection
                      populateCell:(UICollectionViewCell * (^)(UICollectionView *,
                                                               NSIndexPath *,
                                                               FIRDataSnapshot *))populateCell {
  self = [super init];
  if (self) {
    _collection = collection;
    _collection.delegate = self;
    _populateCellAtIndexPath = populateCell;
    _count = 0; // This is zero because RTDB arrays start out at zero
                // and send initial items as a series of adds.
    _displayedSnapshots = [NSMutableArray array];
  }
  return self;
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                 populateCell:(UICollectionViewCell *(^)(UICollectionView *,
                                                         NSIndexPath *,
                                                         FIRDataSnapshot *))populateCell {
  FUIArray *array = [[FUIArray alloc] initWithQuery:query];
  return [self initWithCollection:array populateCell:populateCell];
}

- (NSUInteger)count {
  return _count;
}

- (NSArray<FIRDataSnapshot *> *)items {
  return [self.displayedSnapshots copy];
}

- (FIRDataSnapshot *)snapshotAtIndex:(NSInteger)index {
  return self.displayedSnapshots[index];
}

- (void)bindToView:(UICollectionView *)view {
  self.collectionView = view;
  view.dataSource = self;
  [self.collection observeQuery];
}

- (void)unbind {
  self.collectionView.dataSource = nil;
  self.collectionView = nil;
  [self.collection invalidate];
}

#pragma mark - FUICollectionDelegate methods

// performBatchUpdates: is used for single updates because of this radar:
// https://openradar.appspot.com/26484150
- (void)array:(FUIArray *)array didAddObject:(id)object atIndex:(NSUInteger)index {
  [self enqueueUpdate:^(dispatch_block_t done) {
    [self.collectionView performBatchUpdates:^{
      [self.displayedSnapshots insertObject:object atIndex:index];
      self.count = self.displayedSnapshots.count;
      [self.collectionView
       insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
    } completion:^(BOOL finished) {
      done();
    }];
  }];
}

- (void)array:(FUIArray *)array didChangeObject:(id)object atIndex:(NSUInteger)index {
  [self enqueueUpdate:^(dispatch_block_t done) {
    [self.collectionView performBatchUpdates:^{
      self.displayedSnapshots[index] = object;
      [self.collectionView
       reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
    } completion:^(BOOL finished) {
      done();
    }];
  }];
}

- (void)array:(FUIArray *)array didRemoveObject:(id)object atIndex:(NSUInteger)index {
  [self enqueueUpdate:^(dispatch_block_t done) {
    [self.collectionView performBatchUpdates:^{
      [self.displayedSnapshots removeObjectAtIndex:index];
      self.count = self.displayedSnapshots.count;
      [self.collectionView
       deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
    } completion:^(BOOL finished) {
      done();
    }];
  }];
}

- (void)array:(FUIArray *)array didMoveObject:(id)object
    fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
  [self enqueueUpdate:^(dispatch_block_t done) {
    [self.collectionView performBatchUpdates:^{
      [self.displayedSnapshots removeObjectAtIndex:fromIndex];
      [self.displayedSnapshots insertObject:object atIndex:toIndex];
      [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]
                                   toIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
    } completion:^(BOOL finished) {
      done();
    }];
  }];
}

- (void)array:(id<FUICollection>)array queryCancelledWithError:(NSError *)error {
  if (self.queryErrorHandler != NULL) {
    self.queryErrorHandler(error);
  }
}

- (void)enqueueUpdate:(void (^)(dispatch_block_t done))update {
  if (self.pendingUpdates == nil) {
    self.pendingUpdates = [NSMutableArray array];
  }
  [self.pendingUpdates addObject:update];
  [self flushPendingUpdatesIfNeeded];
}

- (void)flushPendingUpdatesIfNeeded {
  if (self.isApplyingBatchUpdate || self.pendingUpdates.count == 0) {
    return;
  }

  void (^next)(dispatch_block_t) = self.pendingUpdates.firstObject;
  [self.pendingUpdates removeObjectAtIndex:0];
  self.isApplyingBatchUpdate = YES;

  next(^{
    self.isApplyingBatchUpdate = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
      [self flushPendingUpdatesIfNeeded];
    });
  });
}

#pragma mark - UICollectionViewDataSource methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                          cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
  FIRDataSnapshot *snap = self.displayedSnapshots[indexPath.item];

  UICollectionViewCell *cell = self.populateCellAtIndexPath(collectionView, indexPath, snap);

  return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(nonnull UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.count;
}

@end

@implementation UICollectionView (FUICollectionViewDataSource)

- (FUICollectionViewDataSource *)bindToQuery:(FIRDatabaseQuery *)query
                                populateCell:(UICollectionViewCell *(^)(UICollectionView *,
                                                                        NSIndexPath *,
                                                                        FIRDataSnapshot *))populateCell {
  FUICollectionViewDataSource *dataSource =
    [[FUICollectionViewDataSource alloc] initWithQuery:query populateCell:populateCell];
  [dataSource bindToView:self];
  return dataSource;
}

@end
