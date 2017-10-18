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

#import <FirebaseFirestoreUI/FUIBatchedArray.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * FUIFirestoreTableViewDataSource provides a class that conforms to the
 * UITableViewDataSource protocol which allows UITableViews to implement
 * FUIFirestoreTableViewDataSource in order to provide a UITableView synchronized
 * to a Firestore reference or query.
 */
@interface FUIFirestoreTableViewDataSource : NSObject <UITableViewDataSource>

/**
 * The UITableView instance that operations (inserts, removals, moves, etc.) are
 * performed against. This collection view must be receiving data from
 * this data source otherwise data inconsistency crashes will occur.
 */
@property (nonatomic, readwrite, weak, nullable) UITableView *tableView;

/**
 * The number of items in the data source.
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 * The snapshots in the data source.
 */
@property (nonatomic, readonly) NSArray<FIRDocumentSnapshot *> *items;

/**
 * The query from which this data source should load data. When set, the
 * data source will diff the contents of the old and new query and pass an
 * update to the collection view. Diffing is expensive, so try not to do
 * this with very large queries.
 */
@property (nonatomic, readwrite) FIRQuery *query;

/**
 * The type of animation that should be used for animated updates.
 * Defaults to UITableViewRowAnimationAutomatic.
 */
@property (nonatomic, readwrite) UITableViewRowAnimation animation;

/**
 * A closure that should be invoked when the query encounters a fatal error.
 * After this is invoked, the query is no longer valid and the data source should
 * be recreated.
 */
@property (nonatomic, copy, readwrite) void (^queryErrorHandler)(NSError *);

/**
 * Returns the snapshot at the given index. Throws an exception if the index is out of bounds.
 */
- (FIRDocumentSnapshot *)snapshotAtIndex:(NSInteger)index;

/**
 * Initialize an instance of FUIFirestoreTableViewDataSource.
 * @param collection An FUICollection used by the data source to pull data
 *   from Cloud Firestore.
 * @param populateCell A closure used by the data source to create/reuse
 *   table view cells and populate their content. This closure is retained
 *   by the data source, so if you capture self in the closure and also claim ownership
 *   of the data source, be sure to avoid retain cycles by capturing a weak reference to self.
 * @return An instance of FUIFirestoreTableViewDataSource.
 */
- (instancetype)initWithCollection:(FUIBatchedArray *)collection
                      populateCell:(UITableViewCell *(^)(UITableView *tableView,
                                                         NSIndexPath *indexPath,
                                                         FIRDocumentSnapshot *object))populateCell NS_DESIGNATED_INITIALIZER;


/**
 * Initialize an instance of FUIFirestoreTableViewDataSource with contents ordered
 * by the query.
 * @param query A Firestore query to bind the data source to.
 * @param populateCell A closure used by the data source to create/reuse
 *   table view cells and populate their content. This closure is retained
 *   by the data source, so if you capture self in the closure and also claim ownership
 *   of the data source, be sure to avoid retain cycles by capturing a weak reference to self.
 * @return An instance of FUIFirestoreTableViewDataSource.
 */
- (instancetype)initWithQuery:(FIRQuery *)query
                 populateCell:(UITableViewCell *(^)(UITableView *tableView,
                                                    NSIndexPath *indexPath,
                                                    FIRDocumentSnapshot *object))populateCell;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Attaches the data source to a table view and begins sending updates immediately.
 * @param view An instance of UITableView that the data source should push
 *   updates to.
 */
- (void)bindToView:(UITableView *)view;

/**
 * Detaches the data source from a view and stops sending any updates.
 */
- (void)unbind;

@end

@interface UITableView (FUIFirestoreTableViewDataSource)

/**
 * Creates a data source, attaches it to the table view, and returns it.
 * The returned data source is not retained by the table view and must be
 * retained or it will be deallocated while still in use by the table view.
 * @param query A Cloud Firestore query to bind the table view to.
 * @param populateCell A closure used by the data source to create the cells
 *   displayed in the table view. The closure is retained by the returned
 *   data source.
 * @return The created data source. This value must be retained while the table
 *   view is in use.
 */
- (FUIFirestoreTableViewDataSource *)bindToFirestoreQuery:(FIRQuery *)query
    populateCell:(UITableViewCell *(^)(UITableView *tableView,
                                       NSIndexPath *indexPath,
                                       FIRDocumentSnapshot *object))populateCell
                                           __attribute__((warn_unused_result));

@end

NS_ASSUME_NONNULL_END
