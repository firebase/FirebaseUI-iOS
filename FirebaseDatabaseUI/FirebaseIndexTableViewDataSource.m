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

#import "FirebaseIndexTableViewDataSource.h"

#import "FirebaseIndexArray.h"

@interface FirebaseIndexTableViewDataSource () <FirebaseIndexArrayDelegate>

@property (nonatomic, readonly, nonnull) FirebaseIndexArray *array;
@property (nonatomic, readonly, weak) UITableView *tableView;
@property (nonatomic, readonly, copy) NSString *identifier;

@property (nonatomic, readonly, copy) void (^populateCell)(UITableViewCell *, FIRDataSnapshot *);

@end

@implementation FirebaseIndexTableViewDataSource

- (instancetype)init {
  NSException *e =
    [NSException exceptionWithName:@"FIRUnavailableMethodException"
                            reason:@"-init is unavailable. Please use the designated initializer instead."
                          userInfo:nil];
  @throw e;
}

- (instancetype)initWithIndex:(FIRDatabaseQuery *)indexQuery
                         data:(FIRDatabaseReference *)dataQuery
                    tableView:(UITableView *)tableView
          cellReuseIdentifier:(NSString *)cellIdentifier
                     delegate:(nullable id<FirebaseIndexTableViewDataSourceDelegate>)delegate
                 populateCell:(nonnull void (^)(UITableViewCell *cell,
                                                FIRDataSnapshot *data))populateCell {
  self = [super init];
  if (self != nil) {
    _array = [[FirebaseIndexArray alloc] initWithIndex:indexQuery
                                                  data:dataQuery
                                              delegate:self];
    _tableView = tableView;
    tableView.dataSource = self;
    _identifier = [cellIdentifier copy];
    _populateCell = populateCell;
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
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)array:(FirebaseIndexArray *)array
didChangeReference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)array:(FirebaseIndexArray *)array
didRemoveReference:(FIRDatabaseReference *)ref
      atIndex:(NSUInteger)index {
  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)array:(FirebaseIndexArray *)array
didMoveReference:(FIRDatabaseReference *)ref
    fromIndex:(NSUInteger)fromIndex
      toIndex:(NSUInteger)toIndex {
  [self.tableView beginUpdates];
  [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:fromIndex inSection:0]
                         toIndexPath:[NSIndexPath indexPathForRow:toIndex inSection:0]];
  [self.tableView endUpdates];
}

- (void)array:(FirebaseIndexArray *)array
    reference:(FIRDatabaseReference *)ref
didLoadObject:(FIRDataSnapshot *)object
      atIndex:(NSUInteger)index {
  NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
  [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
  FIRDataSnapshot *snap = [self.array objectAtIndex:indexPath.row];
  self.populateCell(cell, snap);
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.array.count;
}

@end
