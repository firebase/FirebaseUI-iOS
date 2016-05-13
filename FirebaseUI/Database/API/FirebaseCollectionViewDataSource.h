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

#import <UIKit/UIKit.h>
#import <FirebaseUI/XCodeMacros.h>

#import "FirebaseDataSource.h"

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
 * The model class to coerce FIRDataSnapshots to (if desired). For instance, if
 * the modelClass is set
 * to [Message class] in Obj-C or Message.self in Swift, then objects of type
 * Message will be
 * returned instead of type FIRDataSnapshot.
 */
@property(strong, nonatomic, __NON_NULL) Class modelClass;

/**
 * The cell class to coerce UICollectionViewCells to (if desired). For instance,
 * if the cellClass is
 * set to [CustomCollectionViewCell class] in Obj-C or CustomCollectionViewCell
 * in Swift, then
 * objects of type CustomCollectionViewCell will be returned instead of type
 * UICollectionViewCell.
 */
@property(strong, nonatomic, __NON_NULL) Class cellClass;

/**
 * The reuse identifier for cells in the UICollectionView.
 */
@property(strong, nonatomic, __NON_NULL) NSString *reuseIdentifier;

/**
 * The UICollectionView instance that operations (inserts, removals, moves,
 * etc.) are performed
 * against.
 */
@property(strong, nonatomic, __NON_NULL) UICollectionView *collectionView;

/**
 * Property to keep track of prototype cell use, to not register a class for the
 * UICollectionView or
 * do similar book keeping.
 */
@property BOOL hasPrototypeCell;

/**
 * The callback to populate a subclass of UICollectionViewCell with an object
 * provided by the
 * datasource.
 */
@property(strong, nonatomic, __NON_NULL) void (^populateCell)
    (__KINDOF(UICollectionViewCell) __NON_NULL_PTR cell, __KINDOF(NSObject) __NON_NULL_PTR object);

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells
 * with FIRDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells with
 * FIRDataSnapshots
 */
- (__NON_NULL instancetype)initWithRef:(__NON_NULL FIRDatabaseReference *)ref
                   cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                  view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells
 * with FIRDataSnapshots. Note that this method is used when using prototype
 * cells, where the cells
 * don't need to be registered in the class.
 * @param ref A Firebase reference to bind the datasource to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells with
 * FIRDataSnapshots
 */
- (__NON_NULL instancetype)initWithRef:(__NON_NULL FIRDatabaseReference *)ref
              prototypeReuseIdentifier:(__NON_NULL NSString *)identifier
                                  view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a
 * custom subclass of
 * UICollectionViewCell with FIRDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param cell A subclass of UICollectionViewCell used to populate the
 * UICollectionView, defaults to
 * UICollectionViewCell if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a
 * custom subclass of
 * UICollectionViewCell with FIRDataSnapshots
 */
- (__NON_NULL instancetype)initWithRef:(__NON_NULL FIRDatabaseReference *)ref
                             cellClass:(__NULLABLE Class)cell
                   cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                  view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a
 * custom xib with
 * FIRDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param nibName The name of a xib file to create the layout for a
 * UICollectionViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a
 * custom xib with
 * FIRDataSnapshots
 */
- (__NON_NULL instancetype)initWithRef:(__NON_NULL FIRDatabaseReference *)ref
                              nibNamed:(__NON_NULL NSString *)nibName
                   cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                  view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells
 * with a custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells with
 * a custom model class
 */
- (__NON_NULL instancetype)initWithRef:(__NON_NULL FIRDatabaseReference *)ref
                            modelClass:(__NULLABLE Class)model
                   cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                  view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells
 * with a custom model class. Note that this method is used when using prototype
 * cells, where the
 * cells don't need to be registered in the class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells with
 * a custom model class
 */
- (__NON_NULL instancetype)initWithRef:(__NON_NULL FIRDatabaseReference *)ref
                            modelClass:(__NULLABLE Class)model
              prototypeReuseIdentifier:(__NON_NULL NSString *)identifier
                                  view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a
 * custom subclass of
 * UICollectionViewCell with a custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param cell A subclass of UICollectionViewCell used to populate the
 * UICollectionView, defaults to
 * UICollectionViewCell if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a
 * custom subclass of
 * UICollectionViewCell with a custom model class
 */
- (__NON_NULL instancetype)initWithRef:(__NON_NULL FIRDatabaseReference *)ref
                            modelClass:(__NULLABLE Class)model
                             cellClass:(__NULLABLE Class)cell
                   cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                  view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a
 * custom xib with a
 * custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param nibName The name of a xib file to create the layout for a
 * UICollectionViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a
 * custom xib with a custom
 * model class
 */
- (__NON_NULL instancetype)initWithRef:(__NON_NULL FIRDatabaseReference *)ref
                            modelClass:(__NULLABLE Class)model
                              nibNamed:(__NON_NULL NSString *)nibName
                   cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                  view:(__NON_NULL UICollectionView *)collectionView;

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
- (__NON_NULL instancetype)initWithQuery:(__NON_NULL FIRDatabaseQuery *)query
                     cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                    view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells
 * with FIRDataSnapshots. Note that this method is used when using prototype
 * cells, where the cells
 * don't need to be registered in the class.
 * @param query A Firebase query to bind the datasource to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells with
 * FIRDataSnapshots
 */
- (__NON_NULL instancetype)initWithQuery:(__NON_NULL FIRDatabaseQuery *)query
                prototypeReuseIdentifier:(__NON_NULL NSString *)identifier
                                    view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a
 * custom subclass of
 * UICollectionViewCell with FIRDataSnapshots.
 * @param query A Firebase query to bind the datasource to
 * @param cell A subclass of UICollectionViewCell used to populate the
 * UICollectionView, defaults to
 * UICollectionViewCell if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a
 * custom subclass of
 * UICollectionViewCell with FIRDataSnapshots
 */
- (__NON_NULL instancetype)initWithQuery:(__NON_NULL FIRDatabaseQuery *)query
                               cellClass:(__NULLABLE Class)cell
                     cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                    view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a
 * custom xib with
 * FIRDataSnapshots.
 * @param query A Firebase query to bind the datasource to
 * @param nibName The name of a xib file to create the layout for a
 * UICollectionViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a
 * custom xib with
 * FIRDataSnapshots
 */
- (__NON_NULL instancetype)initWithQuery:(__NON_NULL FIRDatabaseQuery *)query
                                nibNamed:(__NON_NULL NSString *)nibName
                     cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                    view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells
 * with a custom model class.
 * @param query A Firebase query to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells with
 * a custom model class
 */
- (__NON_NULL instancetype)initWithQuery:(__NON_NULL FIRDatabaseQuery *)query
                              modelClass:(__NULLABLE Class)model
                     cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                    view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells
 * with a custom model class. Note that this method is used when using prototype
 * cells, where the
 * cells don't need to be registered in the class.
 * @param query A Firebase query to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates
 * UICollectionViewCells with
 * a custom model class
 */
- (__NON_NULL instancetype)initWithQuery:(__NON_NULL FIRDatabaseQuery *)query
                              modelClass:(__NULLABLE Class)model
                prototypeReuseIdentifier:(__NON_NULL NSString *)identifier
                                    view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a
 * custom subclass of
 * UICollectionViewCell with a custom model class.
 * @param query A Firebase query to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param cell A subclass of UICollectionViewCell used to populate the
 * UICollectionView, defaults to
 * UICollectionViewCell if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a
 * custom subclass of
 * UICollectionViewCell with a custom model class
 */
- (__NON_NULL instancetype)initWithQuery:(__NON_NULL FIRDatabaseQuery *)query
                              modelClass:(__NULLABLE Class)model
                               cellClass:(__NULLABLE Class)cell
                     cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                    view:(__NON_NULL UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a
 * custom xib with a
 * custom model class.
 * @param query A Firebase query to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param nibName The name of a xib file to create the layout for a
 * UICollectionViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a
 * custom xib with a custom
 * model class
 */
- (__NON_NULL instancetype)initWithQuery:(__NON_NULL FIRDatabaseQuery *)query
                              modelClass:(__NULLABLE Class)model
                                nibNamed:(__NON_NULL NSString *)nibName
                     cellReuseIdentifier:(__NON_NULL NSString *)identifier
                                    view:(__NON_NULL UICollectionView *)collectionView;

/**
 * This method populates the fields of a UICollectionViewCell or subclass given
 * an FIRDataSnapshot (or
 * custom model object).
 * @param callback A block which returns an initialized UICollectionViewCell (or
 * subclass) and the
 * corresponding object to populate the cell with.
 */
- (void)populateCellWithBlock:
    (__NON_NULL void (^)(__KINDOF(UICollectionViewCell)__NON_NULL_PTR cell,
                         __KINDOF(NSObject)__NON_NULL_PTR object))callback;

@end
