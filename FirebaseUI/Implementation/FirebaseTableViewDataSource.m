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

- (instancetype)initWithRef:(Firebase *)ref context:(UITableView *)tableView;
{
    return [self initWithRef:ref model:[FDataSnapshot class] context:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref model:(Class)modelClass context:(UITableView *)tableView;
{
    return [self initWithRef:ref model:modelClass layout:[UITableViewCell class] context:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref model:(Class)modelClass layout:(Class)layoutClass context:(UITableView *)tableView;
{
    return [self initWithRef:ref model:modelClass layout:layoutClass reuseIdentifier:@"CellIdentifier" context:tableView];
}

- (instancetype)initWithRef:(Firebase *)ref model:(Class)modelClass layout:(Class)layoutClass reuseIdentifier:(NSString *)identifier context:(UITableView *)tableView;
{
    FirebaseArray *array = [[FirebaseArray alloc] initWithRef:ref];
    self = [super initWithArray:array];
    if (self) {
        self.tableView = tableView;
        self.modelClass = modelClass;
        self.layoutClass = layoutClass;
        self.reuseIdentifier = identifier;
        
        self.populateCell = ^(id cell, id snap) {};
        
        [self.tableView registerClass:self.layoutClass forCellReuseIdentifier:self.reuseIdentifier];
    }
    return self;
}

- (instancetype)initWithRef:(Firebase *)ref model:(Class)modelClass nibName:(NSString *)name reuseIdentifier:(NSString *)identifier context:(UITableView *)tableView;
{
    FirebaseArray *array = [[FirebaseArray alloc] initWithRef:ref];
    self = [super initWithArray:array];
    if (self) {
        self.tableView = tableView;
        self.modelClass = modelClass;
        self.nibName = name;
        self.reuseIdentifier = identifier;
        
        UINib *nib = [UINib nibWithNibName:self.nibName bundle:[NSBundle mainBundle]];
        [self.tableView registerNib:nib forCellReuseIdentifier:self.reuseIdentifier];
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
