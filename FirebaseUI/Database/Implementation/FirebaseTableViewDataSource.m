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

@implementation FirebaseTableViewDataSource

#pragma mark -
#pragma mark FirebaseDataSource initializer methods

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
   prototypeReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                  cellClass:(Class)cell
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                  modelClass:nil
                   cellClass:cell
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                   nibNamed:(NSString *)nibName
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                  modelClass:nil
                    nibNamed:nibName
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                 modelClass:(Class)model
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                 modelClass:(Class)model
   prototypeReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                 modelClass:(Class)model
                  cellClass:(Class)cell
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                  modelClass:model
                   cellClass:cell
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                 modelClass:(Class)model
                   nibNamed:(NSString *)nibName
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                  modelClass:model
                    nibNamed:nibName
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  return [self initWithQuery:query
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
     prototypeReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  self.hasPrototypeCell = YES;
  return [self initWithQuery:query
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                    cellClass:(Class)cell
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  return [self initWithQuery:query
                  modelClass:nil
                   cellClass:cell
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                     nibNamed:(NSString *)nibName
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  return [self initWithQuery:query
                  modelClass:nil
                    nibNamed:nibName
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                   modelClass:(Class)model
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  return [self initWithQuery:query
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                   modelClass:(Class)model
     prototypeReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  self.hasPrototypeCell = YES;
  return [self initWithQuery:query
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                   modelClass:(Class)model
                    cellClass:(Class)cell
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  FirebaseArray *array = [[FirebaseArray alloc] initWithQuery:query];
  self = [super initWithArray:array];
  if (self) {
    if (!model) {
      model = [FIRDataSnapshot class];
    }

    if (!cell) {
      cell = [UITableViewCell class];
    }

    self.tableView = tableView;
    self.modelClass = model;
    self.reuseIdentifier = identifier;
    self.populateCell = ^(id cell, id object) {
    };

    if (!self.hasPrototypeCell) {
      [self.tableView registerClass:cell forCellReuseIdentifier:self.reuseIdentifier];
    }
  }
  return self;
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                   modelClass:(Class)model
                     nibNamed:(NSString *)nibName
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  FirebaseArray *array = [[FirebaseArray alloc] initWithQuery:query];
  self = [super initWithArray:array];
  if (self) {
    if (!model) {
      model = [FIRDataSnapshot class];
    }

    self.tableView = tableView;
    self.modelClass = model;
    self.reuseIdentifier = identifier;
    self.populateCell = ^(id cell, id object) {
    };

    if (!self.hasPrototypeCell) {
      UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
      [self.tableView registerNib:nib forCellReuseIdentifier:self.reuseIdentifier];
    }
  }
  return self;
}

#pragma mark -
#pragma mark FirebaseCollectionDelegate methods

- (void)childAdded:(id)obj atIndex:(NSUInteger)index {
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)childChanged:(id)obj atIndex:(NSUInteger)index {
  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)childRemoved:(id)obj atIndex:(NSUInteger)index {
  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)childMoved:(id)obj fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
  [self.tableView beginUpdates];
  [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:fromIndex inSection:0]
                         toIndexPath:[NSIndexPath indexPathForRow:toIndex inSection:0]];
  [self.tableView endUpdates];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  id cell = [self.tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier
                                                 forIndexPath:indexPath];

  FIRDataSnapshot *snap = [self.array objectAtIndex:indexPath.row];
  if (![self.modelClass isSubclassOfClass:[FIRDataSnapshot class]]) {
    id model = [[self.modelClass alloc] init];
    // TODO: replace setValuesForKeysWithDictionary with client API
    // valueAsObject method
    [model setValuesForKeysWithDictionary:snap.value];
    self.populateCell(cell, model);
  } else {
    self.populateCell(cell, snap);
  }

  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.array count];
}

- (void)populateCellWithBlock:(void (^)(__kindof UITableViewCell *cell,
                                                   __kindof NSObject *object))callback {
  self.populateCell = callback;
}

@end
