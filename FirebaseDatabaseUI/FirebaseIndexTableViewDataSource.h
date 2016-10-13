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

@import UIKit;

@import FirebaseDatabase;

NS_ASSUME_NONNULL_BEGIN

@class FirebaseIndexTableViewDataSource;

@protocol FirebaseIndexTableViewDataSourceDelegate <NSObject>
@optional

/**
 * Called when an individual reference responsible for populating one cell
 * of the table view has raised an error. This error is unrecoverable, but
 * does not have any effect on the contents of other cells.
 * @param dataSource The FirebaseIndexTableViewDataSource raising the error.
 * @param ref The reference that failed to load.
 * @param index The index (i.e. row) of the query that failed to load.
 * @param error The error that occurred.
 */
- (void)dataSource:(FirebaseIndexTableViewDataSource *)dataSource
         reference:(FIRDatabaseReference *)ref
didFailLoadAtIndex:(NSUInteger)index
         withError:(NSError *)error;

/**
 * Called when the index query used to initialize this data source raised an error.
 * This error is unrecoverable, and likely indicates a bad index query.
 * @param dataSource The FirebaseIndexTableViewDataSource raising the error.
 * @param error The error that occurred.
 */
- (void)dataSource:(FirebaseIndexTableViewDataSource *)dataSource
  indexQueryDidFailWithError:(NSError *)error;

@end

/**
 * An object that manages a @c FirebaseIndexArray and uses it to populate and update
 * a table view with a single section. The data source maintains a reference to but
 * does not claim ownership of the table view that it updates.
 */
@interface FirebaseIndexTableViewDataSource : NSObject <UITableViewDataSource>

/**
 * The delegate that will receive events from this data source.
 */
@property (nonatomic, readwrite, weak, nullable) id<FirebaseIndexTableViewDataSourceDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a table view data source.
 * @param indexQuery The Firebase query containing children of the data query.
 * @param dataQuery The reference whose children correspond to the contents of the
 *   index query. This reference's children's contents are served as teh contents 
 *   of the table view that adopts this data source.
 * @param tableView The table view that is populated by this data source. The
 *   data source pulls updates from Firebase database, so it must maintain a reference
 *   to the table view in order to update its contents as the database pushes updates.
 *   The table view is not retained by its data source.
 * @param cellIdentifier The cell reuse identifier used to dequeue reusable cells from
 *   the table view.
 * @param populateCell The closure invoked when populating a UITableViewCell (or subclass).
 */
- (instancetype)initWithIndex:(FIRDatabaseQuery *)indexQuery
                         data:(FIRDatabaseReference *)dataQuery
                    tableView:(UITableView *)tableView
          cellReuseIdentifier:(NSString *)cellIdentifier
                     delegate:(nullable id<FirebaseIndexTableViewDataSourceDelegate>)delegate
                 populateCell:(void (^)(UITableViewCell *cell,
                                        FIRDataSnapshot *_Nullable))populateCell NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
