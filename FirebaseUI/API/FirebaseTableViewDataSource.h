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

#import <FirebaseUI/FirebaseDataSource.h>

@interface FirebaseTableViewDataSource : FirebaseDataSource <UITableViewDataSource>

/**
 * The model class to coerce FDataSnapshots to (if desired). For instance, if the modelClass is set to [Message class], then objects of type Message will be returned instead of type FDataSnapshot.
 */
@property (strong, nonatomic) Class modelClass;

/**
 * The reuse identifier for cells in the UITableView.
 */
@property (strong, nonatomic) NSString *reuseIdentifier;

/**
 * The UITableView instance that operations (inserts, removals, moves, etc.) are performed against.
 */
@property (strong, nonatomic) UITableView *tableView;

/**
 * The callback to populate a subclass of UITableViewCell with an object provided by the datasource.
 */
@property (strong, nonatomic) void(^populateCell)(id cell, id object);

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates UITableViewCells with FDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates UITableViewCells with FDataSnapshots
 */
- (instancetype)initWithRef:(Firebase *)ref reuseIdentifier:(NSString *)identifier view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom subclass of UITableViewCell with FDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param cell A subclass of UITableViewCell that will
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom subclass of UITableViewCell with FDataSnapshots
 */
- (instancetype)initWithRef:(Firebase *)ref cellClass:(Class)cell reuseIdentifier:(NSString *)identifier view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom xib with FDataSnapshots.
 * @param ref A Firebase reference to bind the datasource to
 * @param nibName The name of a xib file to create the layout for a UITableViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom xib with FDataSnapshots
 */
- (instancetype)initWithRef:(Firebase *)ref nibNamed:(NSString *)nibName reuseIdentifier:(NSString *)identifier view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates UITableViewCells with a custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FDataSnapshots are coerced to
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates UITableViewCells with a custom model class
 */
- (instancetype)initWithRef:(Firebase *)ref modelClass:(Class)model reuseIdentifier:(NSString *)identifier view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom subclass of UITableViewCell with a custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FDataSnapshots are coerced to
 * @param cell A subclass of UITableViewCell that will
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom subclass of UITableViewCell with a custom model class
 */
- (instancetype)initWithRef:(Firebase *)ref modelClass:(Class)model cellClass:(Class)cell reuseIdentifier:(NSString *)identifier view:(UITableView *)tableView;

/**
 * Initialize an instance of FirebaseTableViewDataSource that populates a custom xib with a custom model class.
 * @param ref A Firebase reference to bind the datasource to
 * @param model A custom class that FDataSnapshots are coerced to
 * @param nibName The name of a xib file to create the layout for a UITableViewCell
 * @param identifier A string to use as a CellReuseIdentifier
 * @param tableView An instance of a UITableView to bind to
 * @return An instance of FirebaseTableViewDataSource that populates a custom xib with a custom model class
 */
- (instancetype)initWithRef:(Firebase *)ref modelClass:(Class)model nibNamed:(NSString *)nibName reuseIdentifier:(NSString *)identifier view:(UITableView *)tableView;

/**
 * This method populates the fields of a UITableViewCell or subclass given a model object (or FDataSnapshot).
 * @param callback A block which returns an initialized UITableViewCell (or subclass) and the corresponding object to populate the cell with.
 */
- (void)populateCellWithBlock:(void(^)(id cell, id object))callback;

@end

