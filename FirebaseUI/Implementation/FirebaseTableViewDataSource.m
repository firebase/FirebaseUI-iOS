//
//  FirebaseTableViewDataSource.m
//  Firebase Toolkit
//
//  Created by Mike Mcdonald on 6/26/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <Firebase/Firebase.h>

#import "FirebaseTableViewDataSource.h"

@implementation FirebaseTableViewDataSource

#pragma mark -
#pragma mark FirebaseDataSource initializer methods

- (instancetype)initWithRef:(Firebase *)ref reuseIdentifier:(NSString *)identifier view:(UITableView *)tableView;
{
    return [self initWithRef:ref modelClass:[FDataSnapshot class] reuseIdentifier:identifier view:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref modelClass:(Class)model reuseIdentifier:(NSString *)identifier view:(UITableView *)tableView;
{
    FirebaseArray *array = [[FirebaseArray alloc] initWithRef:ref];
    self = [super initWithArray:array];
    if (self) {
        self.tableView = tableView;
        self.modelClass = model;
        self.reuseIdentifier = identifier;
        self.populateCell = ^(id cell, id snap) {};
    }
    return self;
}

#pragma mark -
#pragma mark FirebaseCollectionDelegate methods

- (void)childAdded:(id)obj atIndex:(NSUInteger)index;
{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)childChanged:(id)obj atIndex:(NSUInteger)index;
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)childMoved:(id)obj fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
{
    [self.tableView beginUpdates];
    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:fromIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:toIndex inSection:0]];
    [self.tableView endUpdates];
}

- (void)childRemoved:(id)obj atIndex:(NSUInteger)index;
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [self createCellWithReuseIdentifier:self.reuseIdentifier atIndexPath:indexPath];
    
    FDataSnapshot *snap = [self.array objectAtIndex:indexPath.row];
    if (![self.modelClass isSubclassOfClass:[FDataSnapshot class]]) {
        id model = [[self.modelClass alloc] init];
        // TODO: replace setValuesForKeysWithDictionary to client API valueAsObject method
        [model setValuesForKeysWithDictionary:snap.value];
        self.populateCell(cell, model);
    } else {
        self.populateCell(cell, snap);
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.array count];
}

- (id)createCellWithReuseIdentifier:(NSString *)identifier atIndexPath:(NSIndexPath *)indexPath;
{
    return [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

- (void)populateCellWithBlock:(void(^)(id cell, id snap))callback;
{
    self.populateCell = callback;
}

@end
