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

#import "FUIArray.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUISortedArray : FUIArray <FUICollection>

/**
 * A copy of the snapshots currently in the array.
 */
@property (nonatomic, readonly, copy) NSArray<FIRDataSnapshot *> *items;

- (instancetype)initWithQuery:(id<FUIDataObservable>)query NS_UNAVAILABLE;
- (instancetype)initWithQuery:(id<FUIDataObservable>)query
                     delegate:(nullable id<FUICollectionDelegate>)delegate NS_UNAVAILABLE;

/**
 * Initializes a sorted collection.
 * @param query The query the receiver uses to pull updates from Firebase Database.
 * @param delegate The delegate object that should receive events from the array.
 * @param sortDescriptor The closure used by the array to sort its contents. This
 *   block must always return consistent results or the array may raise a fatal error.
 */
- (instancetype)initWithQuery:(id<FUIDataObservable>)query
                     delegate:(nullable id<FUICollectionDelegate>)delegate
               sortDescriptor:(NSComparisonResult (^)(FIRDataSnapshot *left,
                                                      FIRDataSnapshot *right))sortDescriptor NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
