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

#import "FUIIndexArray.h"

/**
 * An internal helper class used by FUIIndexArray to manage all its queries.
 */
@interface FUIQueryObserver : NSObject

NS_ASSUME_NONNULL_BEGIN

/// The query observed by this observer.
@property (nonatomic, readonly) id<FUIDataObservable> query;

/// Populated when the query returns a result.
@property (nonatomic, readonly, nullable) FIRDataSnapshot *contents;

/**
 * Initializes a FUIQueryObserver
 */
- (instancetype)initWithQuery:(id<FUIDataObservable>)query NS_DESIGNATED_INITIALIZER;

/**
 * Creates a query observer and immediately starts observing the query.
 */
+ (FUIQueryObserver *)observerForQuery:(id<FUIDataObservable>)query
                                 completion:(void (^_Nullable)(FUIQueryObserver *obs,
                                                               FIRDataSnapshot *_Nullable,
                                                               NSError *_Nullable))completion;

/**
 * Removes all the query's observers. The observer cannot be reused after 
 * this method is called.
 */
- (void)removeAllObservers;

NS_ASSUME_NONNULL_END

@end
