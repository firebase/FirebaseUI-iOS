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

#import "FUIArray.h"
#import "FUITableViewDataSource.h"

@interface FUITableViewDataSource () <FUICollectionDelegate>

@property (strong, nonatomic, readwrite) UITableViewCell *(^populateCell)
  (UITableView *tableView, NSIndexPath *indexPath, FIRDataSnapshot *snap);

@property (strong, nonatomic, readonly) id<FUICollection> collection;

@end

@implementation FUITableViewDataSource

#pragma mark - FUIDataSource initializer methods

- (instancetype)initWithCollection:(id<FUICollection>)collection
                      populateCell:(UITableViewCell *(^)(UITableView *,
                                                         NSIndexPath *,
                                                         FIRDataSnapshot *))populateCell {
  self = [super init];
  if (self != nil) {
    _collection = collection;
    _collection.delegate = self;
    _populateCell = populateCell;
  }
  return self;
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                 populateCell:(UITableViewCell *(^)(UITableView *,
                                                    NSIndexPath *,
                                                    FIRDataSnapshot *))populateCell {
  FUIArray *array = [[FUIArray alloc] initWithQuery:query];
  return [self initWithCollection:array populateCell:populateCell];
}

- (NSUInteger)count {
  return self.collection.count;
}

- (NSArray<FIRDataSnapshot *> *)items {
  return self.collection.items;
}

- (FIRDataSnapshot *)snapshotAtIndex:(NSInteger)index {
  return [self.collection snapshotAtIndex:index];
}

- (void)bindToView:(UITableView *)view {
  self.tableView = view;
  view.dataSource = self;
  [self.collection observeQuery];
}

- (void)unbind {
  self.tableView.dataSource = nil;
  self.tableView = nil;
  [self.collection invalidate];
}

#pragma mark - FUICollectionDelegate methods

- (void)arrayDidBeginUpdates:(id<FUICollection>)collection {
}

- (void)arrayDidEndUpdates:(id<FUICollection>)collection {
}

- (void)array:(FUIArray *)array didAddObject:(id)object atIndex:(NSUInteger)index {
  [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)array:(FUIArray *)array didChangeObject:(id)object atIndex:(NSUInteger)index {
  [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)array:(FUIArray *)array didRemoveObject:(id)object atIndex:(NSUInteger)index {
  [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)array:(FUIArray *)array didMoveObject:(id)object
    fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
  [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:fromIndex inSection:0]
                         toIndexPath:[NSIndexPath indexPathForRow:toIndex inSection:0]];
}

- (void)array:(id<FUICollection>)array queryCancelledWithError:(NSError *)error {
  if (self.queryErrorHandler != NULL) {
    self.queryErrorHandler(error);
  }
}

#pragma mark - UITableViewDataSource methods

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FIRDataSnapshot *snap = [self.collection.items objectAtIndex:indexPath.row];

  UITableViewCell *cell = self.populateCell(tableView, indexPath, snap);
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.collection.count;
}

@end

@implementation UITableView (FUITableViewDataSource)

- (FUITableViewDataSource *)bindToQuery:(FIRDatabaseQuery *)query
                           populateCell:(UITableViewCell *(^)(UITableView *tableView,
                                                              NSIndexPath *indexPath,
                                                              FIRDataSnapshot *snap))populateCell {
  FUITableViewDataSource *dataSource =
    [[FUITableViewDataSource alloc] initWithQuery:query populateCell:populateCell];
  [dataSource bindToView:self];
  return dataSource;
}

@end
