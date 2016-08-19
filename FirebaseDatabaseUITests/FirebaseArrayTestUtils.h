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

#import "FirebaseArray.h"

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
- (instancetype)initWithKey:(NSString *)key value:(NSString *)value;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;
@end

// A dummy observable so we can test this without relying on an internet connection.
@interface FUITestObservable: NSObject <FIRDataObservable>

// Map of handles to observers.
@property (nonatomic, readonly) NSMutableDictionary<NSNumber *, FUIDataEventHandler *> *observers;

// Incremented to generate unique handles.
@property (nonatomic, readonly, assign) FIRDatabaseHandle current;

- (void)removeAllObservers;

// Sends an event to the observable's observers.
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

@interface FUIFirebaseArrayTestDelegate : NSObject <FirebaseArrayDelegate>
@property (nonatomic, copy) void (^queryCancelled)(FirebaseArray *array, NSError *error);
@property (nonatomic, copy) void (^didAddObject)(FirebaseArray *array, id object, NSUInteger index);
@property (nonatomic, copy) void (^didChangeObject)(FirebaseArray *array, id object, NSUInteger index);
@property (nonatomic, copy) void (^didRemoveObject)(FirebaseArray *array, id object, NSUInteger index);
@property (nonatomic, copy) void (^didMoveObject)(FirebaseArray *array, id object, NSUInteger fromIndex, NSUInteger toIndex);
@end

NS_ASSUME_NONNULL_END
