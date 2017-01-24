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

@import Foundation;

#import "FUIArray.h"

@class FIRDatabaseReference;

/**
 * FUIDataSource is a generic superclass for all Firebase datasources,
 * like
 * FUITableViewDataSource and FUICollectionViewDataSource. It provides
 * properties that all
 * subclasses need as well as several methods that pass through to the instance
 * of FirebaseArray.
 */
@interface FUIDataSource : NSObject<FUICollectionDelegate>

/**
 * The items in the data source.
 */
@property (nonatomic, readonly, copy) NSArray *items;

/**
 * The number of items in the receiver's collection.
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 * Takes an FUICollection and immediately starts observing it.
 */
- (instancetype)initWithCollection:(id<FUICollection>)collection NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Returns the snapshot at the given index in the receiver's collection.
 */
- (FIRDataSnapshot *)objectAtIndex:(NSUInteger)index;

/**
 * Provides a block which is called when the backing array cancels its query.
 * @param block the block
 */
- (void)cancelWithBlock:(void (^)(NSError *error))block;

@end
