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

#import "FUIIndexCollectionViewDataSource.h"

#import "FUIIndexArray.h"

@interface FUIIndexCollectionViewDataSource () <FUIIndexArrayDelegate>

@property (nonatomic, readonly, nonnull) FUIIndexArray *array;
@property (nonatomic, readonly, weak) UICollectionView *collectionView;

@property (nonatomic, readonly, copy) UICollectionViewCell *(^populateCell)
  (UICollectionView *collectionView, NSIndexPath *indexPath, FIRDataSnapshot *object);

@end

@implementation FUIIndexCollectionViewDataSource

- (instancetype)initWithIndex:(FIRDatabaseQuery *)indexQuery
                         data:(FIRDatabaseReference *)dataQuery
               collectionView:(UICollectionView *)collectionView
                     delegate:(id<FUIIndexCollectionViewDataSourceDelegate>)delegate
                 populateCell:(UICollectionViewCell *(^)(UICollectionView *collectionView,
                                                         NSIndexPath *indexPath,
                                                         FIRDataSnapshot *snap))populateCell {
  self = [super init];
  if (self != nil) {
    _array = [[FUIIndexArray alloc] initWithIndex:indexQuery
                                                  data:dataQuery
                                              delegate:self];
    _collectionView = collectionView;
    _collectionView.dataSource = self;
    _populateCell = populateCell;
    _delegate = delegate;
  }
  return self;
}

- (NSArray<FIRDataSnapshot *> *)indexes {
  return self.array.indexes;
}

- (FIRDataSnapshot *)snapshotAtIndex:(NSInteger)index {
  return [self.array objectAtIndex:index];
}

#pragma mark - FUIIndexArrayDelegate

- (void)array:(FUIIndexArray *)array
    reference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index
didFailLoadWithError:(NSError *)error {
  if ([self.delegate respondsToSelector:@selector(dataSource:reference:didFailLoadAtIndex:withError:)]) {
    [self.delegate dataSource:self reference:ref didFailLoadAtIndex:index withError:error];
  }
}

- (void)array:(FUIIndexArray *)array queryCancelledWithError:(NSError *)error {
  if ([self.delegate respondsToSelector:@selector(dataSource:indexQueryDidFailWithError:)]) {
    [self.delegate dataSource:self indexQueryDidFailWithError:error];
  }
  NSLog(@"%@ Error: Firebase query cancelled with error %@", self, error);
}

- (void)array:(FUIIndexArray *)array
didAddReference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  [self.collectionView
   insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
}

- (void)array:(FUIIndexArray *)array
didChangeReference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  [self.collectionView
   reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
}

- (void)array:(FUIIndexArray *)array
didRemoveReference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  [self.collectionView
   deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
}

- (void)array:(FUIIndexArray *)array
didMoveReference:(FIRDatabaseReference *)ref
    fromIndex:(NSUInteger)fromIndex
      toIndex:(NSUInteger)toIndex {
  [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]
                               toIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
}

- (void)array:(FUIIndexArray *)array
    reference:(FIRDatabaseReference *)ref
didLoadObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
  [self.collectionView reloadItemsAtIndexPaths:@[path]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  FIRDataSnapshot *snap = [self.array objectAtIndex:indexPath.item];
  UICollectionViewCell *cell = self.populateCell(collectionView, indexPath, snap);
  return cell;
}

@end

@implementation UICollectionView (FUIIndexCollectionViewDataSource)

- (FUIIndexCollectionViewDataSource *)bindToIndexedQuery:(FIRDatabaseQuery *)index
                                                    data:(FIRDatabaseReference *)data
                                                delegate:(id<FUIIndexCollectionViewDataSourceDelegate>)delegate
                                            populateCell:(UICollectionViewCell *(^)(UICollectionView *,
                                                                                    NSIndexPath *,
                                                                                    FIRDataSnapshot *))populateCell {
  FUIIndexCollectionViewDataSource *dataSource =
    [[FUIIndexCollectionViewDataSource alloc] initWithIndex:index
                                                            data:data
                                                  collectionView:self
                                                        delegate:delegate
                                                    populateCell:populateCell];
  self.dataSource = dataSource;
  return dataSource;
}

@end
