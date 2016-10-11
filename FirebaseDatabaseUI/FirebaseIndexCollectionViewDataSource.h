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

@class FirebaseIndexCollectionViewDataSource;

@protocol FirebaseIndexCollectionViewDataSourceDelegate <NSObject>
@optional

/**
 * Called when an individual reference responsible for populating one cell
 * of the collection view has raised an error. This error is unrecoverable, but
 * does not have any effect on the contents of other cells.
 * @param dataSource The FirebaseIndexCollectionViewDataSource raising the error.
 * @param ref The reference that failed to load.
 * @param index The index (i.e. row) of the query that failed to load.
 * @param error The error that occurred.
 */
- (void)dataSource:(FirebaseIndexCollectionViewDataSource *)dataSource
         reference:(FIRDatabaseReference *)ref
didFailLoadAtIndex:(NSUInteger)index
         withError:(NSError *)error;

/**
 * Called when the index query used to initialize this data source raised an error.
 * This error is unrecoverable, and likely indicates a bad index query.
 * @param dataSource The FirebaseIndexCollectionViewDataSource raising the error.
 * @param error The error that occurred.
 */
- (void)dataSource:(FirebaseIndexCollectionViewDataSource *)dataSource
  indexQueryDidFailWithError:(NSError *)error;

@end


@interface FirebaseIndexCollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, readwrite, weak, nullable) id<FirebaseIndexCollectionViewDataSourceDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a collection view data source.
 * @param indexQuery The Firebase query containing children of the data query.
 * @param dataQuery The reference whose children correspond to the contents of the
 *   index query. This reference's children's contents are served as teh contents
 *   of the collection view that adopts this data source.
 * @param collectionView The collection view that is populated by this data source. The
 *   data source pulls updates from Firebase database, so it must maintain a reference
 *   to the collection view in order to update its contents as the database pushes updates.
 *   The collection view is not retained by its data source.
 * @param cellIdentifier The cell reuse identifier used to dequeue reusable cells from
 *   the collection view.
 * @param populateCell The closure invoked when populating a UICollectionViewCell (or subclass).
 */
- (instancetype)initWithIndex:(FIRDatabaseQuery *)indexQuery
                         data:(FIRDatabaseReference *)dataQuery
               collectionView:(UICollectionView *)collectionView
                   identifier:(NSString *)cellIdentifier
                 populateCell:(void (^)(UICollectionViewCell *cell,
                                        FIRDataSnapshot *_Nullable))populateCell NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
