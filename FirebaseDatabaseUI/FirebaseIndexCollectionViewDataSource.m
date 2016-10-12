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

#import "FirebaseIndexCollectionViewDataSource.h"

#import "FirebaseIndexArray.h"

@interface FirebaseIndexCollectionViewDataSource () <FirebaseIndexArrayDelegate>

@property (nonatomic, readonly, nonnull) FirebaseIndexArray *array;
@property (nonatomic, readonly, weak) UICollectionView *collectionView;
@property (nonatomic, readonly, copy) NSString *identifier;

@property (nonatomic, readonly, copy) void (^populateCell)(UICollectionViewCell *, FIRDataSnapshot *);

@end

@implementation FirebaseIndexCollectionViewDataSource

- (instancetype)initWithIndex:(FIRDatabaseQuery *)indexQuery
                         data:(FIRDatabaseReference *)dataQuery
               collectionView:(UICollectionView *)collectionView
          cellReuseIdentifier:(NSString *)cellIdentifier
                     delegate:(id<FirebaseIndexCollectionViewDataSourceDelegate>)delegate
                 populateCell:(void (^)(UICollectionViewCell *,
                                        FIRDataSnapshot *))populateCell {
  self = [super init];
  if (self != nil) {
    _array = [[FirebaseIndexArray alloc] initWithIndex:indexQuery
                                                  data:dataQuery
                                              delegate:self];
    _collectionView = collectionView;
    _collectionView.dataSource = self;
    _identifier = [cellIdentifier copy];
    _populateCell = populateCell;
    _delegate = delegate;
  }
  return self;
}

#pragma mark - FirebaseIndexArrayDelegate

- (void)array:(FirebaseIndexArray *)array
    reference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index
didFailLoadWithError:(NSError *)error {
  if ([self.delegate respondsToSelector:@selector(dataSource:reference:didFailLoadAtIndex:withError:)]) {
    [self.delegate dataSource:self reference:ref didFailLoadAtIndex:index withError:error];
  }
}

- (void)array:(FirebaseIndexArray *)array queryCancelledWithError:(NSError *)error {
  if ([self.delegate respondsToSelector:@selector(dataSource:indexQueryDidFailWithError:)]) {
    [self.delegate dataSource:self indexQueryDidFailWithError:error];
  }
  NSLog(@"%@ Error: Firebase query cancelled with error %@", self, error);
}

- (void)array:(FirebaseIndexArray *)array
didAddReference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  [self.collectionView
   insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
}

- (void)array:(FirebaseIndexArray *)array
didChangeReference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  [self.collectionView
   reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
}

- (void)array:(FirebaseIndexArray *)array
didRemoveReference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  [self.collectionView
   deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
}

- (void)array:(FirebaseIndexArray *)array
didMoveReference:(FIRDatabaseReference *)ref
    fromIndex:(NSUInteger)fromIndex
      toIndex:(NSUInteger)toIndex {
  [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]
                               toIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
}

- (void)array:(FirebaseIndexArray *)array
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
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifier
                                                                         forIndexPath:indexPath];
  FIRDataSnapshot *snap = [self.array objectAtIndex:indexPath.item];
  self.populateCell(cell, snap);
  return cell;
}

@end
