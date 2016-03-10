//
//  FirebaseSet.m
//  FirebaseUI
//
//  Created by Zoe Van Brunt on 11/25/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import "FirebaseSet.h"
#import <Firebase/Firebase.h>

@interface FirebaseSet ()

@property (nonatomic) FirebaseHandle valueHandle;
@property (nonatomic) FirebaseHandle addHandle;
@property (nonatomic) FirebaseHandle removeHandle;
@property (nonatomic) FirebaseHandle changeHandle;

@property (nonatomic, strong) NSMapTable * table;
@property (nonatomic, strong) NSMutableSet * mutableObjects;

@property (nonatomic, strong) NSHashTable * delegates;

@end

@implementation FirebaseSet

#pragma mark Initializer Methods

- (instancetype)initWithRef:(Firebase *)ref;
{
    self = [self init];
    
    _ref = ref;
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _table = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                   valueOptions:NSMapTableWeakMemory];
    
    self.mutableObjects = [NSMutableSet set];
    
    self.delegates = [NSHashTable weakObjectsHashTable];
    
    return self;
}

- (void)dealloc;
{
    [self endAllObservers];
}


#pragma mark Public API Methods

- (void)addDelegate:(id<FirebaseSetDelegate>)delegate;
{
    [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<FirebaseSetDelegate>)delegate;
{
    [self.delegates removeObject:delegate];
}

- (NSSet<id> *)objects;
{
    return [NSSet setWithSet:self.mutableObjects];
}

- (FirebaseSortedData *)sortedData;
{
    return [[FirebaseSortedData alloc] initWithFirebaseSet:self];
}

- (NSUInteger)count;
{
    return [self.mutableObjects count];
}

- (id<FirebaseSetObject>)objectMatchingKey:(NSString *)key;
{
    return [self.table objectForKey:key];
}

#pragma mark Private API Methods

- (id)prepareSnapshot:(FDataSnapshot *)snapshot;
{
    id object;
    
    if (self.classConversionBlock) {
        object = self.classConversionBlock(snapshot);
    } else {
        object = snapshot;
    }
    
    return object;
}

#pragma mark Observer Methods

- (void)initiateObservers;
{
    if (self.addHandle && self.removeHandle && self.changeHandle && self.valueHandle) {
        return;
    }
    FirebaseSet __weak * welf = self;
    
    self.addHandle = [self.ref observeEventType:FEventTypeChildAdded
                                      withBlock:^(FDataSnapshot *snapshot) {
                                          [welf handleAdd:snapshot];
                                      }];
    
    self.removeHandle = [self.ref observeEventType:FEventTypeChildRemoved
                                         withBlock:^(FDataSnapshot *snapshot) {
                                             [welf handleRemove:snapshot];
                                         }];
    
    self.changeHandle = [self.ref observeEventType:FEventTypeChildChanged
                                         withBlock:^(FDataSnapshot *snapshot) {
                                             [welf handleChange:snapshot];
                                         }];
    self.valueHandle = [self.ref observeEventType:FEventTypeValue
                                        withBlock:^(FDataSnapshot *snapshot) {
                                            [welf handleValue:snapshot];
                                        }];
}

- (void)handleValue:(FDataSnapshot *)snapshot;
{
    if (!self.initialValuesSet) {
        [self willChangeValueForKey:@"initialValuesSet"];
        _initialValuesSet = YES;
        [self didChangeValueForKey:@"initialValuesSet"];
        
        for (id <FirebaseSetDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(firebaseSetCompletedInitialization:)]) {
                [delegate firebaseSetCompletedInitialization:self];
            }
        }
    }
    
    for (id <FirebaseSetDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(firebaseSetCompletedUpdates:)]) {
            [delegate firebaseSetCompletedUpdates:self];
        }
    }
}

- (void)handleAdd:(FDataSnapshot *)snapshot;
{
    id preparedObject = [self prepareSnapshot:snapshot];
    
    if (!preparedObject) {
        return;
    }
    
    [self.mutableObjects addObject:preparedObject];
    [self.table setObject:preparedObject forKey:snapshot.key];
    
    for (id <FirebaseSetDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(firebaseSet:added:)]) {
            [delegate firebaseSet:self added:preparedObject];
        }
    }
}

- (void)handleRemove:(FDataSnapshot *)snapshot;
{
    id object = [self.table objectForKey:snapshot.key];
    
    if (!object) {
        return;
    }
    
    [self.mutableObjects removeObject:object];
    [self.table removeObjectForKey:snapshot.key];
    
    for (id <FirebaseSetDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(firebaseSet:removed:)]) {
            [delegate firebaseSet:self removed:object];
        }
    }
}

- (void)handleChange:(FDataSnapshot *)snapshot;
{
    id object = [self.table objectForKey:snapshot.key];
    
    id preparedObject;
    
    if (self.changeHandlerBlock) {
        preparedObject = self.changeHandlerBlock(snapshot, object);
    } else {
        [self.mutableObjects removeObject:object];
        
        preparedObject = [self prepareSnapshot:snapshot];
        [self.mutableObjects addObject:preparedObject];
        [self.table setObject:preparedObject forKey:snapshot.key];
    }
    
    for (id <FirebaseSetDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(firebaseSet:changed:)]) {
            [delegate firebaseSet:self changed:preparedObject];
        }
    }
}

- (void)endAllObservers;
{
    [self.ref removeObserverWithHandle:self.addHandle];
    [self.ref removeObserverWithHandle:self.removeHandle];
    [self.ref removeObserverWithHandle:self.changeHandle];
    [self.ref removeObserverWithHandle:self.valueHandle];
}

@end
