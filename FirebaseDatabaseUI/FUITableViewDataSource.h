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

@import UIKit;

#import "FUIDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@class FIRDatabaseReference;

/**
 * FUITableViewDataSource provides a class that conforms to the
 * UITableViewDataSource protocol which allows UITableViews to implement
 * FUITableViewDataSource in order to provide a UITableView synchronized
 * to a Firebase reference or query.
 */
@interface FUITableViewDataSource : FUIDataSource<UITableViewDataSource>

/**
 * The UITableView instance that operations (inserts, removals, moves, etc.) are
 * performed against.
 */
@property (nonatomic, readonly, weak) UITableView *tableView;

/**
 * The callback used by the data source to populate the table view.
 */
@property(strong, nonatomic, readonly) UITableViewCell *(^populateCell)
  (UITableView *tableView, NSIndexPath *indexPath, FIRDataSnapshot *snap);

/**
 * Initialize an instance of FUITableViewDataSource.
 * @param query A Firebase query to bind the data source to.
 * @param tableView An instance of a UITableView to bind to. This view is
 *   not retained by the data source.
 * @param populateCell A closure used by the data source to create/reuse
 *   table view cells and populate their content. This closure is retained
 *   by the data source, so if you capture self in the closure and also claim ownership
 *   of the data source, be sure to avoid retain cycles by capturing a weak reference to self.
 * @return An instance of FUITableViewDataSource.
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                         view:(UITableView *)tableView
                 populateCell:(UITableViewCell *(^)(UITableView *tableView,
                                                    NSIndexPath *indexPath,
                                                    FIRDataSnapshot *object))populateCell NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithArray:(FUIArray *)array NS_UNAVAILABLE;

@end

@interface UITableView (FUITableViewDataSource)

/**
 * Creates a data source, attaches it to the table view, and returns it.
 * The returned data source is not retained by the table view and must be
 * retained or it will be deallocated while still in use by the table view.
 * @param query A Firebase database query to bind the table view to.
 * @param populateCell A closure used by the data source to create the cells
 *   displayed in the table view. The closure is retained by the returned
 *   data source.
 * @return The created data source. This value must be retained while the table
 *   view is in use.
 */
- (FUITableViewDataSource *)bindToQuery:(FIRDatabaseQuery *)query
                           populateCell:(UITableViewCell *(^)(UITableView *tableView,
                                                              NSIndexPath *indexPath,
                                                              FIRDataSnapshot *object))populateCell __attribute__((warn_unused_result));

@end

NS_ASSUME_NONNULL_END
