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

#import "FirebaseDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@class FIRDatabaseReference;

/**
 * FirebaseTableViewDataSource provides an class that conforms to the
 * UITableViewDataSource protocol
 * which allows UITableViews to implement FirebaseTableViewDataSource in order
 * to provide a
 * UITableView synchronized to a Firebase reference or query. In addition to
 * handling all Firebase
 * child events (added, changed, removed, moved), FirebaseTableViewDataSource
 * handles
 * UITableViewCell creation, either with the default UITableViewCell, prototype
 * cells, custom
 * UITableViewCell subclasses, or custom XIBs, and provides a simple
 * [FirebaseTableViewDataSource
 * populateCellWithBlock:] method which allows developers to populate the cells
 * created for them
 * with desired data from Firebase.
 */
@interface FirebaseTableViewDataSource : FirebaseDataSource<UITableViewDataSource>

/**
 * The model class to coerce FIRDataSnapshots to (if desired). For instance, if
 * the modelClass is set
 * to [Message class] in Obj-C or Message.self in Swift, then objects of type
 * Message will be
 * returned instead of type FIRDataSnapshot.
 */
@property(strong, nonatomic) Class modelClass;

/**
 * The reuse identifier for cells in the UITableView.
 */
@property(strong, nonatomic) NSString *reuseIdentifier;

/**
 * The UITableView instance that operations (inserts, removals, moves, etc.) are
 * performed against.
 */
@property(strong, nonatomic) UITableView *tableView;

/**
 * Property to keep track of prototype cell use, to not register a class for the
 * UICollectionView or
 * do similar book keeping.
 */
@property BOOL hasPrototypeCell;

/**
 * The callback to populate a subclass of UITableViewCell with an object
 * provided by the datasource.
 */
@property(strong, nonatomic) void (^populateCell)
    (__kindof UITableViewCell *cell, __kindof NSObject  *object);

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with
 * FIRDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with
 * FIRDataSnapshots
 */
- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                   cellReuseIdentifier:(NSString *)identifier
                                  view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with
 * FIRDataSnapshots. Note that this method is used when using prototype cells,
 * where the cells don't
 * need to be registered in the class.
 * @param ref A Firebase reference to bind the datasource to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with
 * FIRDataSnapshots
 */
- (instancetype)initWithRef:(FIRDatabaseReference *)ref
              prototypeReuseIdentifier:(NSString *)identifier
                                  view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom
 * subclass of
 * UITableViewCell with FIRDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param cell A subclass of UITableViewCell used to populate the UITableView,
 * defaults to
 * UITableViewCell if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom
 * subclass of
 * UITableViewCell with FIRDataSnapshots
 */
- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                             cellClass:(nullable Class)cell
                   cellReuseIdentifier:(NSString *)identifier
                                  view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom
 * xib with
 * FIRDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param nibName The name of a xib file to create the layout for a
 * UITableViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom
 * xib with
 * FIRDataSnapshots
 */
- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                              nibNamed:(NSString *)nibName
                   cellReuseIdentifier:(NSString *)identifier
                                  view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with a
 * custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with a custom
 * model class
 */
- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                            modelClass:(nullable Class)model
                   cellReuseIdentifier:(NSString *)identifier
                                  view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with a
 * custom model class. Note that this method is used when using prototype cells,
 * where the cells
 * don't need to be registered in the class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with a custom
 * model class
 */
- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                            modelClass:(nullable Class)model
              prototypeReuseIdentifier:(NSString *)identifier
                                  view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom
 * subclass of
 * UITableViewCell with a custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param cell A subclass of UITableViewCell used to populate the UITableView,
 * defaults to
 * UITableViewCell if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom
 * subclass of
 * UITableViewCell with a custom model class
 */
- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                            modelClass:(nullable Class)model
                             cellClass:(nullable Class)cell
                   cellReuseIdentifier:(NSString *)identifier
                                  view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom
 * xib with a custom
 * model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param nibName The name of a xib file to create the layout for a
 * UITableViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom
 * xib with a custom
 * model class
 */
- (instancetype)initWithRef:(FIRDatabaseReference *)ref
                            modelClass:(nullable Class)model
                              nibNamed:(NSString *)nibName
                   cellReuseIdentifier:(NSString *)identifier
                                  view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with
 * FIRDataSnapshots.
 * @param query A Firebase query to bind the datasource to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with
 * FIRDataSnapshots
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                     cellReuseIdentifier:(NSString *)identifier
                                    view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with
 * FIRDataSnapshots. Note that this method is used when using prototype cells,
 * where the cells don't
 * need to be registered in the class.
 * @param query A Firebase query to bind the datasource to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with
 * FIRDataSnapshots
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                prototypeReuseIdentifier:(NSString *)identifier
                                    view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom
 * subclass of
 * UITableViewCell with FIRDataSnapshots.
 * @param query A Firebase query to bind the datasource to
 * @param cell A subclass of UITableViewCell used to populate the UITableView,
 * defaults to
 * UITableViewCell if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom
 * subclass of
 * UITableViewCell with FIRDataSnapshots
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                               cellClass:(nullable Class)cell
                     cellReuseIdentifier:(NSString *)identifier
                                    view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom
 * xib with
 * FIRDataSnapshots.
 * @param query A Firebase query to bind the datasource to
 * @param nibName The name of a xib file to create the layout for a
 * UITableViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom
 * xib with
 * FIRDataSnapshots
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                                nibNamed:(NSString *)nibName
                     cellReuseIdentifier:(NSString *)identifier
                                    view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with a
 * custom model class.
 * @param query A Firebase query to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with a custom
 * model class
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                              modelClass:(nullable Class)model
                     cellReuseIdentifier:(NSString *)identifier
                                    view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with a
 * custom model class. Note that this method is used when using prototype cells,
 * where the cells
 * don't need to be registered in the class.
 * @param query A Firebase query to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates
 * UITableViewCells with a custom
 * model class
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                              modelClass:(nullable Class)model
                prototypeReuseIdentifier:(NSString *)identifier
                                    view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom
 * subclass of
 * UITableViewCell with a custom model class.
 * @param query A Firebase query to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param cell A subclass of UITableViewCell used to populate the UITableView,
 * defaults to
 * UITableViewCell if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom
 * subclass of
 * UITableViewCell with a custom model class
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                              modelClass:(nullable Class)model
                               cellClass:(nullable Class)cell
                     cellReuseIdentifier:(NSString *)identifier
                                    view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom
 * xib with a custom
 * model class.
 * @param query A Firebase query to bind the datasource to
 * @param model A custom class that FIRDataSnapshots are coerced to, defaults to
 * FIRDataSnapshot if nil
 * @param nibName The name of a xib file to create the layout for a
 * UITableViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom
 * xib with a custom
 * model class
 */
- (instancetype)initWithQuery:(FIRDatabaseQuery *)query
                              modelClass:(nullable Class)model
                                nibNamed:(NSString *)nibName
                     cellReuseIdentifier:(NSString *)identifier
                                    view:(UITableView *)tableView;

/**
 * This method populates the fields of a UITableViewCell or subclass given a
 * model object (or
 * FIRDataSnapshot).
 * @param callback A block which returns an initialized UITableViewCell (or
 * subclass) and the
 * corresponding object to populate the cell with.
 */
- (void)populateCellWithBlock:(void (^)(__kindof UITableViewCell *cell, __kindof NSObject *object))callback;

@end

NS_ASSUME_NONNULL_END
