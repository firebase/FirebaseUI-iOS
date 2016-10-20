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

#import "FirebaseTableViewDataSource.h"

@import FirebaseDatabase;

@interface FirebaseTableViewDataSource ()

@property (nonatomic, readwrite, weak) UITableView *tableView;

@property(strong, nonatomic, readwrite) UITableViewCell *(^populateCell)
  (UITableView *tableView, NSIndexPath *indexPath, FIRDataSnapshot *snap);

@end

@implementation FirebaseTableViewDataSource

#pragma mark - FirebaseDataSource initializer methods

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                         view:(UITableView *)tableView
                 populateCell:(UITableViewCell *(^)(UITableView *,
                                                    NSIndexPath *,
                                                    FIRDataSnapshot *))populateCell {
  FirebaseArray *array = [[FirebaseArray alloc] initWithQuery:query];
  self = [super initWithArray:array];
  if (self) {
    self.tableView = tableView;
    self.populateCell = populateCell;
  }
  return self;
}

#pragma mark - FirebaseArrayDelegate methods

- (void)array:(FirebaseArray *)array didAddObject:(id)object atIndex:(NSUInteger)index {
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)array:(FirebaseArray *)array didChangeObject:(id)object atIndex:(NSUInteger)index {
  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)array:(FirebaseArray *)array didRemoveObject:(id)object atIndex:(NSUInteger)index {
  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)array:(FirebaseArray *)array didMoveObject:(id)object
    fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
  [self.tableView beginUpdates];
  [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:fromIndex inSection:0]
                         toIndexPath:[NSIndexPath indexPathForRow:toIndex inSection:0]];
  [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource methods

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FIRDataSnapshot *snap = [self.items objectAtIndex:indexPath.row];

  UITableViewCell *cell = self.populateCell(tableView, indexPath, snap);
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.count;
}

@end
