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

@property (weak, nonatomic) UITableView *tableView;
@property (nonatomic, strong) void(^populateCell)(id cell, id snap);

- (instancetype)initWithRef:(Firebase *)ref context:(UITableView *)tableView;
- (instancetype)initWithRef:(Firebase *)ref model:(Class)modelClass context:(UITableView *)tableView;
- (instancetype)initWithRef:(Firebase *)ref model:(Class)modelClass layout:(Class)layoutClass context:(UITableView *)tableView;
- (instancetype)initWithRef:(Firebase *)ref model:(Class)modelClass layout:(Class)layoutClass reuseIdentifier:(NSString *)identifier context:(UITableView *)tableView;
- (instancetype)initWithRef:(Firebase *)ref model:(Class)modelClass nibName:(NSString *)name reuseIdentifier:(NSString *)identifier context:(UITableView *)tableView;


- (void)populateCellWithBlock:(void(^)(id cell, id snap))callback;

@end

