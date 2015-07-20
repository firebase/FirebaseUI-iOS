//
//  FirebaseTableViewDataSource.h
//  Firebase Toolkit
//
//  Created by Mike Mcdonald on 6/26/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "FirebaseDataSource.h"

@interface FirebaseTableViewDataSource : FirebaseDataSource <UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) void(^populateCell)(id cell, id snap);

- (instancetype)initWithRef:(Firebase *)ref reuseIdentifier:(NSString *)identifier view:(UITableView *)tableView;
- (instancetype)initWithRef:(Firebase *)ref modelClass:(Class)model reuseIdentifier:(NSString *)identifier view:(UITableView *)tableView;

- (void)populateCellWithBlock:(void(^)(id cell, id snap))callback;

@end

