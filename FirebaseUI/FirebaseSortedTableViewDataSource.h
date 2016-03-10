//
//  FirebaseSortedTableViewDataSource.h
//  FirebaseUI
//
//  Created by Zoe Van Brunt on 11/26/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import "FirebaseSortedDataSource.h"
#import "FirebaseSortedDataDelegate.h"
#import <UIKit/UIKit.h>

@interface FirebaseSortedTableViewDataSource : FirebaseSortedDataSource <UITableViewDataSource, FirebaseSortedDataDelegate>

/**
 * The UITableView instance that operations (inserts, removals, moves, etc.) are
 * performed against.
 */
@property (strong, nonatomic) UITableView *tableView;

/**
 * Override to customize UITableView animations.
 */
@property (nonatomic) UITableViewRowAnimation childInsertAnimation;
@property (nonatomic) UITableViewRowAnimation childReloadAnimation;
@property (nonatomic) UITableViewRowAnimation childDeleteAnimation;
@property (nonatomic) UITableViewRowAnimation sectionInsertAnimation;
@property (nonatomic) UITableViewRowAnimation sectionReloadAnimation;
@property (nonatomic) UITableViewRowAnimation sectionDeleteAnimation;

@end
