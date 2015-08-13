/*
 * Firebase UI Bindings iOS Library
 *
 * Copyright © 2015 Firebase - All Rights Reserved
 * https://www.firebase.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>

#import "FirebaseDataSource.h"

@class Firebase;

/**
 * FirebaseCollectionViewDataSource provides an class that conforms to the UICollcetionViewDataSource protocol which allows UICollectionViews to implement FirebaseCollectionViewDataSource in order to provide a UICollectionView synchronized to a Firebase reference or query. In addition to handling all Firebase child events (added, changed, removed, moved), FirebaseCollectionViewDataSource handles UITableViewCell creation, either with the default UICollectionViewCell, prototype cells, custom UICollectionViewCell subclasses, or custom XIBs, and provides a simple [FirebaseCollectionViewDataSource populateCellWithBlock:] method which allows developers to populate the cells created for them with desired data from Firebase.
 */
@interface FirebaseCollectionViewDataSource : FirebaseDataSource <UICollectionViewDataSource>

/**
 * The model class to coerce FDataSnapshots to (if desired). For instance, if the modelClass is set to [Message class] in Obj-C or Message.self in Swift, then objects of type Message will be returned instead of type FDataSnapshot.
 */
@property (strong, nonatomic, nonnull) Class modelClass;

/**
 * The reuse identifier for cells in the UICollectionView.
 */
@property (strong, nonatomic, nonnull) NSString *reuseIdentifier;

/**
 * The UICollectionView instance that operations (inserts, removals, moves, etc.) are performed against.
 */
@property (strong, nonatomic, nonnull) UICollectionView *collectionView;

/**
 * The callback to populate a subclass of UICollectionViewCell with an object provided by the datasource.
 */
@property (strong, nonatomic, nonnull) void(^populateCell)(__nonnull __kindof UICollectionViewCell *cell, __nonnull __kindof NSObject *object);

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates UICollectionViewCells with FDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates UICollectionViewCells with FDataSnapshots
 */
- (nonnull instancetype)initWithRef:(nonnull Firebase *)ref reuseIdentifier:(nonnull NSString *)identifier view:(nonnull UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a custom subclass of UICollectionViewCell with FDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param cell A subclass of UICollectionViewCell used to populate the UICollectionView, defaults to UICollectionViewCell if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a custom subclass of UICollectionViewCell with FDataSnapshots
 */
- (nonnull instancetype)initWithRef:(nonnull Firebase *)ref cellClass:(nullable Class)cell reuseIdentifier:(nonnull NSString *)identifier view:(nonnull UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a custom xib with FDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param nibName The name of a xib file to create the layout for a UICollectionViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a custom xib with FDataSnapshots
 */
- (nonnull instancetype)initWithRef:(nonnull Firebase *)ref nibNamed:(nonnull NSString *)nibName reuseIdentifier:(nonnull NSString *)identifier view:(nonnull UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates UICollectionViewCells with a custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FDataSnapshots are coerced to, defaults to FDataSnapshot if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates UICollectionViewCells with a custom model class
 */
- (nonnull instancetype)initWithRef:(nonnull Firebase *)ref modelClass:(nullable Class)model reuseIdentifier:(nonnull NSString *)identifier view:(nonnull UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a custom subclass of UICollectionViewCell with a custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FDataSnapshots are coerced to, defaults to FDataSnapshot if nil
 * @param cell A subclass of UICollectionViewCell used to populate the UICollectionView, defaults to UICollectionViewCell if nil
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a custom subclass of UICollectionViewCell with a custom model class
 */
- (nonnull instancetype)initWithRef:(nonnull Firebase *)ref modelClass:(nullable Class)model cellClass:(nullable Class)cell reuseIdentifier:(nonnull NSString *)identifier view:(nonnull UICollectionView *)collectionView;

/**
 * Initialize an instance of FirebaseCollectionViewDataSource that populates a custom xib with a custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FDataSnapshots are coerced to, defaults to FDataSnapshot if nil
 * @param nibName The name of a xib file to create the layout for a UICollectionViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param collectionView An instance of a UICollectionView to bind to
 * @return An instance of FirebaseCollectionViewDataSource that populates a custom xib with a custom model class
 */
- (nonnull instancetype)initWithRef:(nonnull Firebase *)ref modelClass:(nullable Class)model nibNamed:(nonnull NSString *)nibName reuseIdentifier:(nonnull NSString *)identifier view:(nonnull UICollectionView *)collectionView;

/**
 * This method populates the fields of a UICollectionViewCell or subclass given an FDataSnapshot (or custom model object).
 * @param callback A block which returns an initialized UICollectionViewCell (or subclass) and the corresponding object to populate the cell with.
 */
- (void)populateCellWithBlock:(nonnull void(^)(__nonnull __kindof UICollectionViewCell *cell, __nonnull __kindof NSObject *object))callback;

@end
