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

#import "FUIIndexTableViewDataSource.h"

#import "FUIIndexArray.h"

@interface FUIIndexTableViewDataSource () <FUIIndexArrayDelegate>

@property (nonatomic, readonly, nonnull) FUIIndexArray *array;
@property (nonatomic, readonly, weak) UITableView *tableView;

@property (nonatomic, readonly, copy) UITableViewCell *(^populateCell)
  (UITableView *tableView, NSIndexPath *indexPath, FIRDataSnapshot *snap);

@end

@implementation FUIIndexTableViewDataSource

- (instancetype)init {
  NSException *e =
    [NSException exceptionWithName:@"FIRUnavailableMethodException"
                            reason:@"-init is unavailable. Please use the designated initializer instead."
                          userInfo:nil];
  @throw e;
}

- (instancetype)initWithIndex:(FIRDatabaseQuery *)indexQuery
                         data:(FIRDatabaseReference *)dataQuery
                     delegate:(nullable id<FUIIndexTableViewDataSourceDelegate>)delegate
                 populateCell:(UITableViewCell *(^)(UITableView *tableView,
                                                    NSIndexPath *indexPath,
                                                    FIRDataSnapshot *snap))populateCell {
  self = [super init];
  if (self != nil) {
    _array = [[FUIIndexArray alloc] initWithIndex:indexQuery
                                             data:dataQuery
                                         delegate:self];
    _populateCell = populateCell;
    _delegate = delegate;
  }
  return self;
}

- (void)bindToTableView:(UITableView *)tableView {
  _tableView = tableView;
  tableView.dataSource = self;
  [self.array observeQueries];
}

- (NSArray<FIRDataSnapshot *> *)indexes {
  return self.array.indexes;
}

- (FIRDataSnapshot *)snapshotAtIndex:(NSInteger)index {
  return [self.array objectAtIndex:index];
}

- (void)dealloc {
  [self.array invalidate];
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
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)array:(FUIIndexArray *)array
didChangeReference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)array:(FUIIndexArray *)array
didRemoveReference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)array:(FUIIndexArray *)array
didMoveReference:(FIRDatabaseReference *)ref
    fromIndex:(NSUInteger)fromIndex
      toIndex:(NSUInteger)toIndex {
  [self.tableView beginUpdates];
  [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:fromIndex inSection:0]
                         toIndexPath:[NSIndexPath indexPathForRow:toIndex inSection:0]];
  [self.tableView endUpdates];
}

- (void)array:(FUIIndexArray *)array
    reference:(FIRDatabaseReference *)ref
didLoadObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
  [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FIRDataSnapshot *snap = [self.array objectAtIndex:indexPath.row];
  UITableViewCell *cell = self.populateCell(tableView, indexPath, snap);
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.array.count;
}

@end

@implementation UITableView (FUIIndexTableViewDataSource)

- (FUIIndexTableViewDataSource *)bindToIndexedQuery:(FIRDatabaseQuery *)index
                                               data:(FIRDatabaseReference *)data
                                           delegate:(id<FUIIndexTableViewDataSourceDelegate>)delegate
                                       populateCell:(UITableViewCell *(^)(UITableView *,
                                                                          NSIndexPath *,
                                                                          FIRDataSnapshot *))populateCell {
  FUIIndexTableViewDataSource *dataSource =
    [[FUIIndexTableViewDataSource alloc] initWithIndex:index
                                                  data:data
                                              delegate:delegate
                                          populateCell:populateCell];
  [dataSource bindToTableView:self];
  return dataSource;
}

@end
