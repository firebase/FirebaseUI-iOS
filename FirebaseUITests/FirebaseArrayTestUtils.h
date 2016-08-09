//
//  FirebaseArrayTestUtils.h
//  FirebaseUI
//
//  Created by Morgan Chen on 8/8/16.
//  Copyright © 2016 Firebase, Inc. All rights reserved.
//

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
@property (nonatomic, copy) NSString *key;
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

// Inserts sequentially with data provided by the `generator` block.
- (void)populateWithCount:(NSUInteger)count generator:(FUIFakeSnapshot *(^)(NSUInteger))generator;

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
