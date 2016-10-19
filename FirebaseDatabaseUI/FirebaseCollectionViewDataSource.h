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

#import "FirebaseDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@class FIRDatabaseReference;

/**
 * FirebaseCollectionViewDataSource provides an class that conforms to the
 * UICollcetionViewDataSource protocol which allows UICollectionViews to
 * implement
 * FirebaseCollectionViewDataSource in order to provide a UICollectionView
 * synchronized to a
 * Firebase reference or query. In addition to handling all Firebase child
 * events (added, changed,
 * removed, moved), FirebaseCollectionViewDataSource handles UITableViewCell
 * creation, either with
 * the default UICollectionViewCell, prototype cells, custom
 * UICollectionViewCell subclasses, or
 * custom XIBs, and provides a simple [FirebaseCollectionViewDataSource
 * populateCellWithBlock:]
 * method which allows developers to populate the cells created for them with
 * desired data from
 * Firebase.
 */
@interface FirebaseCollectionViewDataSource : FirebaseDataSource<UICollectionViewDataSource>

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
  (NSIndexPath *indexPath, UICollectionView *collectionView, FIRDataSnapshot *object);

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells
 * with FIRDataSnapshots.
 * @param query A Firebase query to bind the datasource to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells with
 * FIRDataSnapshots
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                         view:(UICollectionView *)collectionView
                 populateCell:(UICollectionViewCell * (^)(NSIndexPath *indexPath,
                                                          UICollectionView *collectionView,
                                                          FIRDataSnapshot *object))populateCell;

@end

NS_ASSUME_NONNULL_END
