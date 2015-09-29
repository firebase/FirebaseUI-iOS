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
            sortDescriptors:(NSArray *)sortDescriptors
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
    return [self initWithRef:ref
             sortDescriptors:sortDescriptors
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

-(instancetype)initWithRef:(Firebase *)ref
           sortDescriptors:(NSArray *)sortDescriptors
  prototypeReuseIdentifier:(NSString *)identifier
                      view:(UITableView *)tableView {
    self.hasPrototypeCell = YES;
    return [self initWithRef:ref
             sortDescriptors:sortDescriptors
                  modelClass:nil
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

-(instancetype)initWithRef:(Firebase *)ref
           sortDescriptors:(NSArray *)sortDescriptors
                modelClass:(Class)model
       cellReuseIdentifier:(NSString *)identifier
                      view:(UITableView *)tableView {
    return [self initWithRef:ref
             sortDescriptors:sortDescriptors
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

-(instancetype)initWithRef:(Firebase *)ref
           sortDescriptors:(NSArray *)sortDescriptors
                  nibNamed:(NSString *)nibName
       cellReuseIdentifier:(NSString *)identifier
                      view:(UITableView *)tableView {
    return [self initWithRef:ref
             sortDescriptors:sortDescriptors
                  modelClass:nil
                    nibNamed:nibName
         cellReuseIdentifier:identifier
                        view:tableView];
}

-(instancetype)initWithRef:(Firebase *)ref
           sortDescriptors:(NSArray *)sortDescriptors
                 cellClass:(Class)cell
       cellReuseIdentifier:(NSString *)identifier
                      view:(UITableView *)tableView {
    return [self initWithRef:ref
             sortDescriptors:sortDescriptors
                  modelClass:nil
                   cellClass:cell
         cellReuseIdentifier:identifier
                        view:tableView];
    
}

-(instancetype)initWithRef:(Firebase *)ref
           sortDescriptors:(NSArray *)sortDescriptors
                modelClass:(Class)model
  prototypeReuseIdentifier:(NSString *)identifier
                      view:(UITableView *)tableView {
    self.hasPrototypeCell = YES;
    return [self initWithRef:ref
             sortDescriptors:sortDescriptors
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

-(instancetype)initWithRef:(Firebase *)ref
           sortDescriptors:(NSArray *)sortDescriptors
                modelClass:(Class)model
                 cellClass:(Class)cell
       cellReuseIdentifier:(NSString *)identifier
                      view:(UITableView *)tableView {
    return [self initWithRef:ref
                   predicate:nil
             sortDescriptors:sortDescriptors
                  modelClass:model
                   cellClass:cell
         cellReuseIdentifier:identifier
                        view:tableView];
}

-(instancetype)initWithRef:(Firebase *)ref
           sortDescriptors:(NSArray *)sortDescriptors
                modelClass:(Class)model
                  nibNamed:(NSString *)nibName
       cellReuseIdentifier:(NSString *)identifier
                      view:(UITableView *)tableView {
    
    return [self initWithRef:ref
                   predicate:nil
             sortDescriptors:sortDescriptors
                  modelClass:model
                    nibNamed:nibName
         cellReuseIdentifier:identifier
                        view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithRef:ref
                modelClass:nil
                 cellClass:nil
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
   prototypeReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  self.hasPrototypeCell = YES;
  return [self initWithRef:ref
                modelClass:nil
                 cellClass:nil
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
                  cellClass:(Class)cell
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithRef:ref
                modelClass:nil
                 cellClass:cell
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
                   nibNamed:(NSString *)nibName
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithRef:ref
                modelClass:nil
                  nibNamed:nibName
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
                 modelClass:(Class)model
        cellReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  return [self initWithRef:ref
                modelClass:model
                 cellClass:nil
       cellReuseIdentifier:identifier
                      view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref
                 modelClass:(Class)model
   prototypeReuseIdentifier:(NSString *)identifier
                       view:(UITableView *)tableView {
  self.hasPrototypeCell = YES;
  return [self initWithRef:ref
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
    return [self initWithRef:ref
             sortDescriptors:nil
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
    
    return [self initWithRef:ref
             sortDescriptors:nil
                  modelClass:model
                    nibNamed:nibName
         cellReuseIdentifier:identifier
                        view:tableView];
}

-(instancetype)initWithRef:(Firebase *)ref
                 predicate:(NSPredicate *)predicate
           sortDescriptors:(NSArray *)sortDescriptors
                modelClass:(Class)model
  prototypeReuseIdentifier:(NSString *)identifier
                      view:(UITableView *)tableView {
    self.hasPrototypeCell = YES;
    return [self initWithRef:ref
                   predicate:predicate
             sortDescriptors:sortDescriptors
                  modelClass:model
                   cellClass:nil
         cellReuseIdentifier:identifier
                        view:tableView];
}

-(instancetype)initWithRef:(Firebase *)ref
                 predicate:(NSPredicate *)predicate
           sortDescriptors:(NSArray *)sortDescriptors
                modelClass:(Class)model
                 cellClass:(Class)cell
       cellReuseIdentifier:(NSString *)identifier
                      view:(UITableView *)tableView {
    FirebaseArray *array = [[FirebaseArray alloc] initWithQuery:ref
                                                sortDescriptors:sortDescriptors
                                                      predicate:predicate];
    self = [super initWithArray:array];
    if (!self) {
        return nil;
    }
    
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
        [self.tableView registerClass:cell
               forCellReuseIdentifier:self.reuseIdentifier];
    }
    return self;
}

-(instancetype)initWithRef:(Firebase *)ref
                 predicate:(NSPredicate *)predicate
           sortDescriptors:(NSArray *)sortDescriptors
                modelClass:(Class)model
                  nibNamed:(NSString *)nibName
       cellReuseIdentifier:(NSString *)identifier
                      view:(UITableView *)tableView {
    FirebaseArray *array = [[FirebaseArray alloc] initWithQuery:ref
                                                sortDescriptors:sortDescriptors
                                                      predicate:predicate];
    self = [super initWithArray:array];
    if (!self) {
        return nil;
    }
    
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
        [self.tableView registerNib:nib
             forCellReuseIdentifier:self.reuseIdentifier];
    }
    return self;
}

#pragma mark -
#pragma mark FirebaseCollectionDelegate methods

- (void)childAdded:(id)obj atIndexPath:(NSIndexPath *)indexPath {
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:@[indexPath]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)childChanged:(id)obj atIndexPath:(NSIndexPath *)indexPath {
  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)childRemoved:(id)obj atIndexPath:(NSIndexPath *)indexPath {
  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)childMoved:(id)obj
         fromIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
  [self.tableView beginUpdates];
  [self.tableView
      moveRowAtIndexPath:fromIndexPath
             toIndexPath:toIndexPath];
  [self.tableView endUpdates];
}

- (void)sectionAddedAtSectionIndex:(NSUInteger)section {
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)sectionRemovedAtSectionIndex:(NSUInteger)section {
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)beginUpdates {
    [self.tableView beginUpdates];
}

-(void)endUpdates {
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (id)tableView:(UITableView *)tableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  id cell =
      [self.tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier
                                           forIndexPath:indexPath];

  FDataSnapshot *snap = [self.array objectAtIndexPath:indexPath];
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self sectionTitleForSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return [self.array sectionAtIndex:section].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.array.sectionKeyPath) {
        return [self.array.sectionValues count];
    }
    return 1;
}

- (void)populateCellWithBlock:
    (__NON_NULL void (^)(__KINDOF(UITableViewCell)__NON_NULL_PTR cell,
                         __KINDOF(NSObject)__NON_NULL_PTR object))callback {
  self.populateCell = callback;
}

@end
