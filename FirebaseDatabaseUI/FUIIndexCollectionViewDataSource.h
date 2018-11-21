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

#import <FirebaseDatabase/FirebaseDatabase.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FUIIndexCollectionViewDataSource, FUIIndexArray;

@protocol FUIIndexCollectionViewDataSourceDelegate <NSObject>
@optional

/**
 * Called when an individual reference responsible for populating one cell
 * of the collection view has raised an error. This error is unrecoverable, but
 * does not have any effect on the contents of other cells.
 * @param dataSource The FUIIndexCollectionViewDataSource raising the error.
 * @param ref The reference that failed to load.
 * @param index The index (i.e. row) of the query that failed to load.
 * @param error The error that occurred.
 */
- (void)dataSource:(FUIIndexCollectionViewDataSource *)dataSource
         reference:(FIRDatabaseReference *)ref
didFailLoadAtIndex:(NSUInteger)index
         withError:(NSError *)error;

/**
 * Called when the index query used to initialize this data source raised an error.
 * This error is unrecoverable, and likely indicates a bad index query.
 * @param dataSource The FUIIndexCollectionViewDataSource raising the error.
 * @param error The error that occurred.
 */
- (void)dataSource:(FUIIndexCollectionViewDataSource *)dataSource
  indexQueryDidFailWithError:(NSError *)error;

@end

/**
 * An object that manages a @c FUIIndexArray and uses it to populate and update
 * a collection view with a single section. The data source maintains a reference to but
 * does not claim ownership of the collection view that it updates.
 */
@interface FUIIndexCollectionViewDataSource : NSObject <UICollectionViewDataSource>

/**
 * The delegate that should receive updates from this data source. Implement this delegate
 * to handle load errors and successes.
 */
@property (nonatomic, readwrite, weak, nullable) id<FUIIndexCollectionViewDataSourceDelegate> delegate;

/**
 * The indexes that have finished loading in the data source. Returns an empty array if no indexes
 * have loaded.
 */
@property (nonatomic, readonly, copy) NSArray<FIRDataSnapshot *> *indexes;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a collection view data source.
 * @param indexArray The FUIIndexArray whose contents will be displayed in the collection view.
 * @param populateCell The closure invoked when populating a UICollectionViewCell (or subclass).
 */
- (instancetype)initWithIndexArray:(FUIIndexArray *)indexArray
                          delegate:(nullable id<FUIIndexCollectionViewDataSourceDelegate>)delegate
                      populateCell:(UICollectionViewCell *(^)(UICollectionView *collectionView,
                                                              NSIndexPath *indexPath,
                                                              FIRDataSnapshot *_Nullable snap))populateCell
                                                                  NS_DESIGNATED_INITIALIZER;

/**
 * Initializes a collection view data source.
 * @param indexQuery The Firebase query containing children of the data query.
 * @param dataQuery The reference whose children correspond to the contents of the
 *   index query. This reference's children's contents are served as the contents
 *   of the collection view that adopts this data source.
 * @param populateCell The closure invoked when populating a UICollectionViewCell (or subclass).
 */
- (instancetype)initWithIndex:(FIRDatabaseQuery *)indexQuery
                         data:(FIRDatabaseReference *)dataQuery
                     delegate:(nullable id<FUIIndexCollectionViewDataSourceDelegate>)delegate
                 populateCell:(UICollectionViewCell *(^)(UICollectionView *collectionView,
                                                         NSIndexPath *indexPath,
                                                         FIRDataSnapshot *_Nullable snap))populateCell;

/**
 * Returns the snapshot at the given index, if it has loaded.
 * Raises a fatal error if the index is out of bounds.
 * @param index The index of the requested snapshot.
 * @return A snapshot, or nil if one has not yet been loaded.
 */
- (nullable FIRDataSnapshot *)snapshotAtIndex:(NSInteger)index;

/**
 * Attaches the data source to a collection view and begins sending updates immediately.
 * @param view The collection view that is populated by this data source. The
 *   data source pulls updates from Firebase database, so it must maintain a reference
 *   to the collection view in order to update its contents as the database pushes updates.
 *   The collection view is not retained by its data source.
 */
- (void)bindToView:(UICollectionView *)view;

/**
 * Detaches the data source from a view and stops sending any updates.
 */
- (void)unbind;

@end

@interface UICollectionView (FUIIndexCollectionViewDataSource)

/**
 * Creates a data source, attaches it to the collection view, and returns it.
 * The returned data source is not retained by the collection view and must be
 * retained or it will be deallocated while still in use by the collection view.
 * @param index The Firebase query containing children of the data query.
 * @param data  The reference whose children correspond to the contents of the
 *   index query. This reference's children's contents are served as the contents
 *   of the collection view.
 * @param delegate The object that should respond to events from the data source.
 * @param populateCell A closure used by the data source to create the cells
 *   displayed in the collection view. The closure is retained by the returned
 *   data source.
 * @return The created data source. This value must be retained while the collection
 *   view is in use.
 */
- (FUIIndexCollectionViewDataSource *)bindToIndexedQuery:(FIRDatabaseQuery *)index
                                                    data:(FIRDatabaseReference *)data
                                                delegate:(id<FUIIndexCollectionViewDataSourceDelegate>)delegate
                                            populateCell:(UICollectionViewCell *(^)(UICollectionView *view,
                                                                                    NSIndexPath *indexPath,
                                                                                    FIRDataSnapshot *_Nullable snap))populateCell __attribute__((warn_unused_result));

@end


NS_ASSUME_NONNULL_END
