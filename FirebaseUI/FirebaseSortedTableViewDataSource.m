//
//  FirebaseSortedTableViewDataSource.m
//  FirebaseUI
//
//  Created by Zoe Van Brunt on 11/26/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import "FirebaseSortedTableViewDataSource.h"
#import "FirebaseSortedData.h"

@implementation FirebaseSortedTableViewDataSource

- (instancetype)init;
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.childInsertAnimation = UITableViewRowAnimationAutomatic;
    self.childReloadAnimation = UITableViewRowAnimationAutomatic;
    self.childDeleteAnimation = UITableViewRowAnimationAutomatic;
    self.sectionInsertAnimation = UITableViewRowAnimationAutomatic;
    self.sectionReloadAnimation = UITableViewRowAnimationAutomatic;
    self.sectionDeleteAnimation = UITableViewRowAnimationAutomatic;
    
    return self;
}

#pragma mark -
#pragma mark FirebaseCollectionDelegate methods

- (void)childAdded:(id)obj atIndexPath:(NSIndexPath *)indexPath;
{
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:self.childInsertAnimation];
}

- (void)childChanged:(id)obj atIndexPath:(NSIndexPath *)indexPath;
{
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:self.childReloadAnimation];
}

- (void)childRemoved:(id)obj atIndexPath:(NSIndexPath *)indexPath;
{
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:self.childDeleteAnimation];
}

- (void)sectionAddedAtSectionIndex:(NSUInteger)section;
{
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section]
                  withRowAnimation:self.sectionInsertAnimation];
}

- (void)sectionRemovedAtSectionIndex:(NSUInteger)section;
{
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section]
                  withRowAnimation:self.sectionDeleteAnimation];
}

- (void)reload;
{
    [self.tableView reloadData];
}

-(void)beginUpdates;
{
    [self.tableView beginUpdates];
}

-(void)endUpdates;
{
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell =
    [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier
                                    forIndexPath:indexPath];
    
    id obj = [self.data objectAtIndexPath:indexPath];
    
    if (self.populateCellBlock) {
        self.populateCellBlock(cell, obj);
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self sectionTitleForSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = [self.data numberOfObjectsInSection:section];
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger sections = [self.data numberOfSections];
    return sections;
}

#pragma mark -
#pragma mark Public API methods

- (void)setCellReuseIdentifier:(NSString *)cellReuseIdentifier {
    [super setCellReuseIdentifier:cellReuseIdentifier];
    
    if (self.hasPrototypeCell) {
        return;
    }
    
    if (self.nibName) {
        [self.tableView registerNib:[UINib nibWithNibName:self.nibName bundle:nil]
             forCellReuseIdentifier:cellReuseIdentifier];
    } else if (self.cellClass) {
        [self.tableView registerClass:self.cellClass forCellReuseIdentifier:cellReuseIdentifier];
    }
}

@end
