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

#import "FUIFirestoreTableViewDataSource.h"

@interface FUIFirestoreTableViewDataSource () <FUIBatchedArrayDelegate>

@property (strong, nonatomic, readwrite) UITableViewCell *(^populateCell)
  (UITableView *tableView, NSIndexPath *indexPath, FIRDocumentSnapshot *snap);

@property (strong, nonatomic, readonly) FUIBatchedArray *collection;

@end

@implementation FUIFirestoreTableViewDataSource

#pragma mark - FUIDataSource initializer methods

- (instancetype)initWithCollection:(FUIBatchedArray *)collection
                      populateCell:(UITableViewCell *(^)(UITableView *,
                                                         NSIndexPath *,
                                                         FIRDocumentSnapshot *))populateCell {
  self = [super init];
  if (self != nil) {
    _collection = collection;
    _collection.delegate = self;
    _populateCell = populateCell;
    _animation = UITableViewRowAnimationAutomatic;
  }
  return self;
}

- (instancetype)initWithQuery:(FIRQuery *)query
                 populateCell:(UITableViewCell *(^)(UITableView *,
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
  return [self.collection objectAtIndex:index];
}

- (void)bindToView:(UITableView *)view {
  self.tableView = view;
  view.dataSource = self;
  [self.collection observeQuery];
}

- (void)unbind {
  self.tableView.dataSource = nil;
  self.tableView = nil;
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
  [self.tableView beginUpdates];

  NSMutableArray *deletedIndexPaths =
      [NSMutableArray arrayWithCapacity:diff.deletedIndexes.count];
  for (NSNumber *deletedIndex in diff.deletedIndexes) {
    NSIndexPath *deleted = [NSIndexPath indexPathForRow:deletedIndex.integerValue inSection:0];
    [deletedIndexPaths addObject:deleted];
  }
  [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths
                        withRowAnimation:self.animation];

  NSMutableArray *changedIndexPaths =
      [NSMutableArray arrayWithCapacity:diff.changedIndexes.count];
  for (NSNumber *changedIndex in diff.changedIndexes) {
    NSIndexPath *changed = [NSIndexPath indexPathForRow:changedIndex.integerValue inSection:0];
    [changedIndexPaths addObject:changed];
  }
  [self.tableView reloadRowsAtIndexPaths:changedIndexPaths
                        withRowAnimation:self.animation];

  for (NSInteger i = 0; i < diff.movedInitialIndexes.count; i++) {
    NSInteger initialIndex = diff.movedInitialIndexes[i].integerValue;
    NSInteger finalIndex   = diff.movedResultIndexes[i].integerValue;
    NSIndexPath *initialPath = [NSIndexPath indexPathForRow:initialIndex inSection:0];
    NSIndexPath *finalPath   = [NSIndexPath indexPathForRow:finalIndex inSection:0];

    [self.tableView moveRowAtIndexPath:initialPath toIndexPath:finalPath];
  }

  NSMutableArray *insertedIndexPaths =
      [NSMutableArray arrayWithCapacity:diff.insertedIndexes.count];
  for (NSNumber *insertedIndex in diff.insertedIndexes) {
    NSIndexPath *inserted = [NSIndexPath indexPathForRow:insertedIndex.integerValue inSection:0];
    [insertedIndexPaths addObject:inserted];
  }
  [self.tableView insertRowsAtIndexPaths:insertedIndexPaths
                        withRowAnimation:self.animation];

  [self.tableView endUpdates];
}

- (void)batchedArray:(FUIBatchedArray *)array queryDidFailWithError:(NSError *)error {
  if (self.queryErrorHandler != nil) {
    self.queryErrorHandler(error);
  } else {
    NSLog(@"%@ Unhandled Firestore error: %@. Set the queryErrorHandler property to debug.",
          self, error);
  }
}

#pragma mark - UITableViewDataSource methods

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FIRDocumentSnapshot *snap = [self.collection.items objectAtIndex:indexPath.row];
  UITableViewCell *cell = self.populateCell(tableView, indexPath, snap);
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.collection.count;
}

@end

@implementation UITableView (FUIFirestoreTableViewDataSource)

- (FUIFirestoreTableViewDataSource *)bindToFirestoreQuery:(FIRQuery *)query
    populateCell:(UITableViewCell *(^)(UITableView *tableView,
                                       NSIndexPath *indexPath,
                                       FIRDocumentSnapshot *snap))populateCell {
  FUIFirestoreTableViewDataSource *dataSource =
      [[FUIFirestoreTableViewDataSource alloc] initWithQuery:query populateCell:populateCell];
  [dataSource bindToView:self];
  return dataSource;
}

@end
