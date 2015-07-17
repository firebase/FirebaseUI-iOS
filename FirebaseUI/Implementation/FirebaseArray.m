//
//  FirebaseArray.m
//  FirebaseToolkit
//
//  Created by Mike Mcdonald on 7/8/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <Firebase/Firebase.h>

#import "FirebaseArray.h"

@implementation FirebaseArray

#pragma mark -
#pragma mark Initializer methods

- (instancetype)initWithRef:(Firebase *)ref;
{
    return [self initWithQuery:ref];
}

- (instancetype)initWithQuery:(Firebase *)ref;
{
    self = [super init];
    if (self) {
        self.snapshots = [NSMutableArray array];
        self.ref = ref;
        
        [self initListeners];
    }
    return self;
}


#pragma mark -
#pragma mark Memory management methods

- (void)dealloc;
{
    // Possibly consider keeping track of these and only removing them if they are explicitly added here
    [self.ref removeAllObservers];
}

#pragma mark -
#pragma mark Private API methods

- (void)initListeners;
{
    [self.ref observeEventType:FEventTypeChildAdded andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger index = [self indexForKey:previousChildKey] + 1;

        [self.snapshots insertObject:snapshot atIndex:index];
        
        [self.delegate childAdded:snapshot atIndex:index];
    }];
    
    [self.ref observeEventType:FEventTypeChildMoved andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger fromIndex = [self indexForKey:snapshot.key];
        NSUInteger toIndex = [self indexForKey:previousChildKey] + 1;

        [self.snapshots removeObject:snapshot];
        [self.snapshots insertObject:snapshot atIndex:toIndex];
            
        [self.delegate childMoved:snapshot fromIndex:fromIndex toIndex:toIndex];
    }];

    [self.ref observeEventType:FEventTypeChildChanged andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger index = [self indexForKey:previousChildKey] + 1;
            
        [self.snapshots replaceObjectAtIndex:index withObject:snapshot];

        [self.delegate childChanged:snapshot atIndex:index];
    }];
    
    [self.ref observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        NSUInteger index = [self indexForKey:snapshot.key];

        [self.snapshots removeObject:snapshot];

        [self.delegate childRemoved:snapshot atIndex:index];
    }];
}

- (NSUInteger)indexForKey:(NSString *)key;
{
    if (!key) return -1;
    
    for (NSUInteger index = 0; index < [self.snapshots count]; index++) {
        if ([key isEqualToString:[(FDataSnapshot *)[self.snapshots objectAtIndex:index] key]]) {
            return index;
        }
    }
    
    @throw [NSException exceptionWithName:@"KeyNotFound" reason:@"" userInfo:@{}];
}


#pragma mark -
#pragma mark Public API methods

- (NSUInteger)count;
{
    return [self.snapshots count];
}

- (FDataSnapshot *)objectAtIndex:(NSUInteger)index;
{
    return (FDataSnapshot *)[self.snapshots objectAtIndex:index];
}

- (Firebase *)refForIndex:(NSUInteger)index;
{
    return [(FDataSnapshot *)[self.snapshots objectAtIndex:index] ref];
}

@end
