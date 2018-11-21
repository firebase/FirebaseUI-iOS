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

#import "FUIBatchedArray.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * FUIFirestoreCollectionViewDataSource provides a class that conforms to the
 * UICollectionViewDataSource protocol which allows UICollectionViews to
 * adopt FUIFirestoreCollectionViewDataSource in order to provide a UICollectionView
 * synchronized to a Firestore reference or query.
 */
@interface FUIFirestoreCollectionViewDataSource : NSObject <UICollectionViewDataSource>

/**
 * The UICollectionView instance that operations (inserts, removals, moves,
 * etc.) are performed against. The data source does not claim ownership of
 * the collection view it populates. This collection view must be receiving data
 * from this data source otherwise data inconsistency crashes will occur.
 */
@property (nonatomic, readwrite, weak, nullable) UICollectionView *collectionView;

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
 * A closure that should be invoked when the query encounters a fatal error. 
 * After this is invoked, the query is no longer valid and the data source should
 * be recreated.
 */
@property (nonatomic, copy, readwrite, nullable) void (^queryErrorHandler)(NSError *);

/**
 * Returns the snapshot at the given index. Throws an exception if the index is out of bounds.
 */
- (FIRDocumentSnapshot *)snapshotAtIndex:(NSInteger)index;

/**
 * Initialize an instance of FUIFirestoreCollectionViewDataSource that populates
 * UICollectionViewCells with FIRDataSnapshots.
 * @param collection A FUICollection that the data source uses to pull snapshots
 *   from Cloud Firestore.
 * @param populateCell A closure used by the data source to create the cells that
 *   are displayed in the collection view. This closure is retained by the data
 *   source, so if you capture self in the closure and also claim ownership of the
 *   data source, be sure to avoid retain cycles by capturing a weak reference to self.
 * @return An instance of FUIFirestoreCollectionViewDataSource that populates
 *   UICollectionViewCells with FIRDataSnapshots.
 */
- (instancetype)initWithCollection:(FUIBatchedArray *)collection
                      populateCell:(UICollectionViewCell *(^)(UICollectionView *collectionView,
                                                              NSIndexPath *indexPath,
                                                              FIRDocumentSnapshot *object))populateCell NS_DESIGNATED_INITIALIZER;

/**
 * Initialize an unsorted instance of FUIFirestoreCollectionViewDataSource that populates
 * UICollectionViewCells with FIRDataSnapshots.
 * @param query A Firestore query to bind the data source to.
 * @param populateCell A closure used by the data source to create the cells that 
 *   are displayed in the collection view. This closure is retained by the data
 *   source, so if you capture self in the closure and also claim ownership of the
 *   data source, be sure to avoid retain cycles by capturing a weak reference to self.
 * @return An instance of FUIFirestoreCollectionViewDataSource that populates
 *   UICollectionViewCells with FIRDataSnapshots.
 */
- (instancetype)initWithQuery:(FIRQuery *)query
                 populateCell:(UICollectionViewCell *(^)(UICollectionView *collectionView,
                                                         NSIndexPath *indexPath,
                                                         FIRDocumentSnapshot *object))populateCell;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Attaches the data source to a collection view and begins sending updates immediately.
 * @param view An instance of UICollectionView that the data source should push
 *   updates to.
 */
- (void)bindToView:(UICollectionView *)view;

/**
 * Detaches the data source from a view and stops sending any updates.
 */
- (void)unbind;

@end

@interface UICollectionView (FUIFirestoreCollectionViewDataSource)

/**
 * Creates a data source, attaches it to the collection view, and returns it.
 * The returned data source is not retained by the collection view and must be
 * retained or it will be deallocated while still in use by the collection view.
 * @param query A Cloud Firestore query to bind the collection view to.
 * @param populateCell A closure used by the data source to create the cells
 *   displayed in the collection view. The closure is retained by the returned
 *   data source.
 * @return The created data source. This value must be retained while the collection
 *   view is in use.
 */
- (FUIFirestoreCollectionViewDataSource *)bindToFirestoreQuery:(FIRQuery *)query
    populateCell:(UICollectionViewCell *(^)(UICollectionView *collectionView,
                                            NSIndexPath *indexPath,
                                            FIRDocumentSnapshot *object))populateCell
                                                __attribute__((warn_unused_result));

@end

NS_ASSUME_NONNULL_END
