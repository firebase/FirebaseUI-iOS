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

@class FUIArray;

/**
 * A protocol to allow instances of FUIArray to raise events through a
 * delegate. Raises all Firebase events except FIRDataEventTypeValue.
 */
@protocol FUIArrayDelegate<NSObject>

@optional

/**
 * Delegate method which is called whenever an object is added to an FUIArray.
 * On a FUIArray synchronized to a Firebase reference, this corresponds to a
 * @c FIRDataEventTypeChildAdded event being raised.
 * @param object The object added to the FUIArray
 * @param index The index the child was added at
 */
- (void)array:(FUIArray *)array didAddObject:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is changed in an
 * FUIArray. On a FUIArray synchronized to a Firebase reference, this
 * corresponds to a @c FIRDataEventTypeChildChanged event being raised.
 * @param object The object that changed in the FUIArray
 * @param index The index the child was changed at
 */
- (void)array:(FUIArray *)array didChangeObject:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is removed from an
 * FUIArray. On a FUIArray synchronized to a Firebase reference, this
 * corresponds to a @c FIRDataEventTypeChildRemoved event being raised.
 * @param object The object removed from the FUIArray
 * @param index The index the child was removed at
 */
- (void)array:(FUIArray *)array didRemoveObject:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is moved within a
 * FUIArray. On a FUIArray synchronized to a Firebase reference, this
 * corresponds to a @c FIRDataEventTypeChildMoved event being raised.
 * @param object The object that has moved locations in the FUIArray
 * @param fromIndex The index the child is being moved from
 * @param toIndex The index the child is being moved to
 */
- (void)array:(FUIArray *)array didMoveObject:(id)object fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

/**
 * Delegate method which is called whenever the backing query is canceled.
 * @param error the error that was raised
 */
- (void)array:(FUIArray *)array queryCancelledWithError:(NSError *)error;

@end
