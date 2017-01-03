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

#import "FUIArray.h"

@import FirebaseDatabaseUI;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

// Dumb object holding a pair of blocks and a data event type.
@interface FUIDataEventHandler: NSObject
@property (nonatomic, assign) FIRDataEventType event;
@property (nonatomic, copy) void (^success)(FIRDataSnapshot *_Nonnull, NSString *_Nullable);
@property (nonatomic, copy) void (^cancelled)(NSError *_Nonnull);
@end

// Horrible abuse of ObjC type system, since FirebaseArray is unfortunately coupled to
// FIRDataSnapshot
@interface FUIFakeSnapshot: NSObject
- (instancetype)initWithKey:(NSString *)key value:(id)value;
+ (instancetype)snapWithKey:(NSString *)key value:(id)value;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) id value;
@end

// A dummy observable so we can test this without relying on an internet connection.
@interface FUITestObservable: NSObject <FUIDataObservable>

// The initialized observable behaves like a FIRDatabaseQuery and pretends the
// provided dict is serialized JSON.
- (instancetype)initWithDictionary:(NSDictionary *)contents NS_DESIGNATED_INITIALIZER;

// Appends an object to the observable's contents and sends a child added event to the
// observable's observers.
- (void)addObject:(id)object forKey:(NSString *)key;

// Removes an object from the observable's contents and sends a child removed event
// to the observable's observers.
- (void)removeObjectForKey:(NSString *)key;

// Updates the value for the provided key and sends a child changed event to the
// observable's observers.
- (void)changeObject:(id)object forKey:(NSString *)key;

// Moves a value for the provided index and sends a child moved event to the observable's
// observers.
- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;

// Map of handles to observers.
@property (nonatomic, readonly) NSMutableDictionary<NSNumber *, FUIDataEventHandler *> *observers;

// Incremented to generate unique handles.
@property (nonatomic, readonly, assign) FIRDatabaseHandle current;

- (void)removeAllObservers;

// Sends an event to the observable's observers. This could be more
// robust--currently it depends on the tester knowing what the "correct"
// previousKey is supposed to be.
- (void)sendEvent:(FIRDataEventType)event
       withObject:(nullable FUIFakeSnapshot *)object
      previousKey:(nullable NSString *)string
            error:(nullable NSError *)error;

// Inserts sequentially with data provided by the `generator` block. Snapshot keys
// are increasing integers as strings, snapshot values are strings returned by the
// `generator` block.
- (void)populateWithCount:(NSUInteger)count generator:(NSString *(^)(NSUInteger))generator;

// Sends a bunch of insertion events with snapshot keys as integer strings (i.e. @"0") of increasing
// order, starting from 0.
- (void)populateWithCount:(NSUInteger)count;

@end

@interface FUIArrayTestDelegate : NSObject <FUICollectionDelegate>
@property (nonatomic, copy) void (^didStartUpdates)();
@property (nonatomic, copy) void (^didEndUpdates)();
@property (nonatomic, copy) void (^queryCancelled)(id<FUICollection> array, NSError *error);
@property (nonatomic, copy) void (^didAddObject)(id<FUICollection> array, id object, NSUInteger index);
@property (nonatomic, copy) void (^didChangeObject)(id<FUICollection> array, id object, NSUInteger index);
@property (nonatomic, copy) void (^didRemoveObject)(id<FUICollection> array, id object, NSUInteger index);
@property (nonatomic, copy) void (^didMoveObject)(id<FUICollection> array, id object, NSUInteger fromIndex, NSUInteger toIndex);
@end

@interface FUIIndexArrayTestDelegate : NSObject <FUIIndexArrayDelegate>
@property (nonatomic, copy) void (^didLoad)(FUIIndexArray *array, FIRDatabaseReference *ref, FIRDataSnapshot *snap, NSUInteger index);
@property (nonatomic, copy) void (^didFail)(FUIIndexArray *array, FIRDatabaseReference *ref, NSUInteger index, NSError *error);
@property (nonatomic, copy) void (^queryCancelled)(FUIIndexArray *array, NSError *error);
@property (nonatomic, copy) void (^didAddQuery)(FUIIndexArray *array, FIRDatabaseReference *query, NSUInteger index);
@property (nonatomic, copy) void (^didChangeQuery)(FUIIndexArray *array, FIRDatabaseReference *query, NSUInteger index);
@property (nonatomic, copy) void (^didRemoveQuery)(FUIIndexArray *array, FIRDatabaseReference *query, NSUInteger index);
@property (nonatomic, copy) void (^didMoveQuery)(FUIIndexArray *array, FIRDatabaseReference *query, NSUInteger fromIndex, NSUInteger toIndex);
@end

NS_ASSUME_NONNULL_END
