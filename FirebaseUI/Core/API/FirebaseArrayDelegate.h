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

/**
 * A protocol to allow instances of FirebaseArray to raise events through a
 * delegate. Raises all
 * Firebase events except FIRDataEventTypeValue.
 */
@protocol FirebaseArrayDelegate<NSObject>

@optional

/**
 * Delegate method which is called whenever an object is added to a
 * FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FIRDataEventTypeChildAdded](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The object added to the FirebaseArray
 * @param index The index the child was added at
 */
- (void)childAdded:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is chinged in a
 * FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FIRDataEventTypeChildChanged](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The object that changed in the FirebaseArray
 * @param index The index the child was changed at
 */
- (void)childChanged:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is removed from a
 * FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FIRDataEventTypeChildRemoved](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The object removed from the FirebaseArray
 * @param index The index the child was removed at
 */
- (void)childRemoved:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is moved within a
 * FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FIRDataEventTypeChildMoved](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The object that has moved locations in the FirebaseArray
 * @param fromIndex The index the child is being moved from
 * @param toIndex The index the child is being moved to
 */
- (void)childMoved:(id)object fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

/**
 * Delegate method which is called whenever the backing query is canceled.
 * @param error the error that was raised
 */
- (void)canceledWithError:(NSError *)error;

@end
