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
    id cell = [self.tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier forIndexPath:indexPath];
    
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

- (void)populateCellWithBlock:(void(^)(id cell, id snap))callback;
{
    self.populateCell = callback;
}

@end
