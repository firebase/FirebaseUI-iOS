// clang-format off

/*
 * Firebase UI Bindings iOS Library
 *
 * Copyright © 2015 Firebase - All Rights Reserved
 * https://www.firebase.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// clang-format on

#import <Firebase/Firebase.h>

#import "FirebaseTableViewDataSource.h"

@implementation FirebaseTableViewDataSource

#pragma mark -
#pragma mark FirebaseDataSource initializer methods

- (instancetype)initWithRef:(Firebase *)ref
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                modelClass:nil
                 cellClass:nil
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
   prototypeReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                modelClass:nil
                 cellClass:nil
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
                  cellClass:(Class)cell
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                modelClass:nil
                 cellClass:cell
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
                   nibNamed:(NSString *)nibName
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                modelClass:nil
                  nibNamed:nibName
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
                 modelClass:(Class)model
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                modelClass:model
                 cellClass:nil
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
                 modelClass:(Class)model
   prototypeReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithQuery:ref
                modelClass:model
                 cellClass:nil
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
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

- (instancetype)initWithRef:(Firebase *)ref
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

- (instancetype)initWithQuery:(FQuery *)query
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  return [self initWithQuery:query
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FQuery *)query
     prototypeReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  self.hasPrototypeCell = YES;
  return [self initWithQuery:query
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FQuery *)query
                    cellClass:(Class)cell
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  return [self initWithQuery:query
                  modelClass:nil
                   cellClass:cell
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FQuery *)query
                     nibNamed:(NSString *)nibName
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  return [self initWithQuery:query
                  modelClass:nil
                    nibNamed:nibName
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FQuery *)query
                   modelClass:(Class)model
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  return [self initWithQuery:query
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithQuery:(FQuery *)query
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

- (instancetype)initWithQuery:(FQuery *)query
                   modelClass:(Class)model
                    cellClass:(Class)cell
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  FirebaseArray *array = [[FirebaseArray alloc] initWithQuery:query];
  self = [super initWithArray:array];
  if (self) {
    if (!model) {
      model = [FDataSnapshot class];
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

- (instancetype)initWithQuery:(FQuery *)query
                   modelClass:(Class)model
                     nibNamed:(NSString *)nibName
          cellReuseIdentifier:(NSString *)identifier
                         view:(UITableView *)tableView {
  FirebaseArray *array = [[FirebaseArray alloc] initWithQuery:query];
  self = [super initWithArray:array];
  if (self) {
    if (!model) {
      model = [FDataSnapshot class];
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

-(void)childrenInitialized{
    [self.tableView reloadData];
}

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

  FDataSnapshot *snap = [self.array objectAtIndex:indexPath.row];
  if (![self.modelClass isSubclassOfClass:[FDataSnapshot class]]) {
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

- (void)populateCellWithBlock:(__NON_NULL void (^)(__KINDOF(UITableViewCell)__NON_NULL_PTR cell,
                                                   __KINDOF(NSObject)
                                                       __NON_NULL_PTR object))callback {
  self.populateCell = callback;
}

@end
