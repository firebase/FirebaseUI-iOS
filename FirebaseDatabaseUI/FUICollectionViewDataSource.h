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
 * FUICollectionViewDataSource provides a class that conforms to the
 * UICollectionViewDataSource protocol which allows UICollectionViews to
 * adopt FUICollectionViewDataSource in order to provide a UICollectionView
 * synchronized to a Firebase reference or query.
 */
@interface FUICollectionViewDataSource : FUIDataSource<UICollectionViewDataSource>

/**
 * The UICollectionView instance that operations (inserts, removals, moves,
 * etc.) are performed against. The data source does not claim ownership of
 * the collection view it populates.
 */
@property (nonatomic, readonly, weak) UICollectionView *collectionView;

/**
 * The callback to populate a subclass of UICollectionViewCell with an object
 * provided by the datasource.
 */
@property(strong, nonatomic, readonly) UICollectionViewCell *(^populateCellAtIndexPath)
  (UICollectionView *collectionView, NSIndexPath *indexPath, FIRDataSnapshot *object);

/**
 * Initialize an instance of FUICollectionViewDataSource that populates
 * UICollectionViewCells with FIRDataSnapshots.
 * @param query A Firebase query to bind the data source to.
 * @param collectionView An instance of a UICollectionView to bind to. This view
 *   is not retained by its data source.
 * @param populateCell A closure used by the data source to create the cells that 
 *   are displayed in the collection view. This closure is retained by the data
 *   source, so if you capture self in the closure and also claim ownership of the
 *   data source, be sure to avoid retain cycles by capturing a weak reference to self.
 * @return An instance of FUICollectionViewDataSource that populates
 *   UICollectionViewCells with FIRDataSnapshots.
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                         view:(UICollectionView *)collectionView
                 populateCell:(UICollectionViewCell *(^)(UICollectionView *collectionView,
                                                         NSIndexPath *indexPath,
                                                         FIRDataSnapshot *object))populateCell NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithArray:(FUIArray *)array NS_UNAVAILABLE;

@end

@interface UICollectionView (FUICollectionViewDataSource)

/**
 * Creates a data source, attaches it to the collection view, and returns it.
 * The returned data source is not retained by the collection view and must be
 * retained or it will be deallocated while still in use by the collection view.
 * @param query A Firebase database query to bind the collection view to.
 * @param populateCell A closure used by the data source to create the cells
 *   displayed in the collection view. The closure is retained by the returned
 *   data source.
 * @return The created data source. This value must be retained while the collection
 *   view is in use.
 */
- (FUICollectionViewDataSource *)bindToQuery:(FIRDatabaseQuery *)query
                                populateCell:(UICollectionViewCell *(^)(UICollectionView *collectionView,
                                                                        NSIndexPath *indexPath,
                                                                        FIRDataSnapshot *object))populateCell __attribute__((warn_unused_result));

@end

NS_ASSUME_NONNULL_END
