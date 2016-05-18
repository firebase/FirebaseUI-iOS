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

#import "FirebaseCollectionViewDataSource.h"

@import FirebaseDatabase;

@implementation FirebaseCollectionViewDataSource

#pragma mark -
#pragma mark FirebaseDataSource initializer methods

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
        cellReuseIdentifier:(NSString *)identifier
                       view:(UICollectionView *)collectionView {
  return [self initWithQuery:ref
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
   prototypeReuseIdentifier:(NSString *)identifier
                       view:(UICollectionView *)collectionView {
  return [self initWithQuery:ref
                    modelClass:nil
      prototypeReuseIdentifier:identifier
                          view:collectionView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                  cellClass:(Class)cell
        cellReuseIdentifier:(NSString *)identifier
                       view:(UICollectionView *)collectionView {
  return [self initWithQuery:ref
                  modelClass:nil
                   cellClass:cell
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                   nibNamed:(NSString *)nibName
        cellReuseIdentifier:(NSString *)identifier
                       view:(UICollectionView *)collectionView {
  return [self initWithQuery:ref
                  modelClass:nil
                    nibNamed:nibName
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                 modelClass:(Class)model
        cellReuseIdentifier:(NSString *)identifier
                       view:(UICollectionView *)collectionView {
  return [self initWithQuery:ref
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                 modelClass:(Class)model
   prototypeReuseIdentifier:(NSString *)identifier
                       view:(UICollectionView *)collectionView {
  return [self initWithQuery:ref
                    modelClass:model
      prototypeReuseIdentifier:identifier
                          view:collectionView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                 modelClass:(Class)model
                  cellClass:(Class)cell
        cellReuseIdentifier:(NSString *)identifier
                       view:(UICollectionView *)collectionView {
  return [self initWithQuery:ref
                  modelClass:model
                   cellClass:cell
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                 modelClass:(Class)model
                   nibNamed:(NSString *)nibName
        cellReuseIdentifier:(NSString *)identifier
                       view:(UICollectionView *)collectionView {
  return [self initWithQuery:ref
                  modelClass:model
                    nibNamed:nibName
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
          cellReuseIdentifier:(NSString *)identifier
                         view:(UICollectionView *)collectionView {
  return [self initWithQuery:query
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
     prototypeReuseIdentifier:(NSString *)identifier
                         view:(UICollectionView *)collectionView {
  self.hasPrototypeCell = YES;
  return [self initWithQuery:query
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                    cellClass:(Class)cell
          cellReuseIdentifier:(NSString *)identifier
                         view:(UICollectionView *)collectionView {
  return [self initWithQuery:query
                  modelClass:nil
                   cellClass:cell
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                     nibNamed:(NSString *)nibName
          cellReuseIdentifier:(NSString *)identifier
                         view:(UICollectionView *)collectionView {
  return [self initWithQuery:query
                  modelClass:nil
                    nibNamed:nibName
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                   modelClass:(Class)model
          cellReuseIdentifier:(NSString *)identifier
                         view:(UICollectionView *)collectionView {
  return [self initWithQuery:query
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                   modelClass:(Class)model
     prototypeReuseIdentifier:(NSString *)identifier
                         view:(UICollectionView *)collectionView {
  self.hasPrototypeCell = YES;
  return [self initWithQuery:query
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:collectionView];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                   modelClass:(Class)model
                    cellClass:(Class)cell
          cellReuseIdentifier:(NSString *)identifier
                         view:(UICollectionView *)collectionView {
  FirebaseArray *array = [[FirebaseArray alloc] initWithQuery:query];
  self = [super initWithArray:array];
  if (self) {
    if (!model) {
      model = [FIRDataSnapshot class];
    }

    if (!cell) {
      cell = [UICollectionViewCell class];
    }

    self.collectionView = collectionView;
    self.modelClass = model;
    self.cellClass = cell;
    self.reuseIdentifier = identifier;
    self.populateCell = ^(id cell, id object) {
    };

    if (!self.hasPrototypeCell) {
      [self.collectionView registerClass:self.cellClass
              forCellWithReuseIdentifier:self.reuseIdentifier];
    }
  }
  return self;
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                   modelClass:(Class)model
                     nibNamed:(NSString *)nibName
          cellReuseIdentifier:(NSString *)identifier
                         view:(UICollectionView *)collectionView {
  FirebaseArray *array = [[FirebaseArray alloc] initWithQuery:query];
  self = [super initWithArray:array];
  if (self) {
    if (!model) {
      model = [FIRDataSnapshot class];
    }

    self.collectionView = collectionView;
    self.modelClass = model;
    self.reuseIdentifier = identifier;
    self.populateCell = ^(id cell, id object) {
    };

    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:self.reuseIdentifier];
  }
  return self;
}

#pragma mark -
#pragma mark FirebaseCollectionDelegate methods

- (void)childAdded:(id)obj atIndex:(NSUInteger)index {
  [self.collectionView
      insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index inSection:0] ]];
}

- (void)childChanged:(id)obj atIndex:(NSUInteger)index {
  [self.collectionView
      reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]];
}

- (void)childRemoved:(id)obj atIndex:(NSUInteger)index {
  [self.collectionView
      deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]];
}

- (void)childMoved:(id)obj fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
  [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForRow:fromIndex inSection:0]
                               toIndexPath:[NSIndexPath indexPathForRow:toIndex inSection:0]];
}

#pragma mark -
#pragma mark UICollectionViewDataSource methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                          cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
  id cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier
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

- (NSInteger)numberOfSectionsInCollectionView:(nonnull UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return [self.array count];
}

- (void)populateCellWithBlock:
    (void (^)(__kindof UICollectionViewCell *cell,
                         __kindof NSObject *object))callback {
  self.populateCell = callback;
}

@end
