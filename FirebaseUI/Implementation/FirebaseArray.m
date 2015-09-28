// clang-format off

/*
 * Firebase UI Bindings iOS Library
 *
 * Copyright © 2015 Firebase - All Rights Reserved
 * https://www.firebase.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// clang-format on

#import <Firebase/Firebase.h>

#import "FirebaseArray.h"

@implementation FirebaseArray {
    FirebaseHandle _addHandle;
    FirebaseHandle _changeHandle;
    FirebaseHandle _removeHandle;
    FirebaseHandle _moveHandle;
}

#pragma mark -
#pragma mark Initializer methods

- (instancetype)initWithRef:(Firebase *)ref {
  return [self initWithQuery:ref];
}

- (instancetype)initWithQuery:(FQuery *)query {
  self = [super init];
  if (self) {
    self.snapshots = [NSMutableArray array];
    self.query = query;

    [self initListeners];
  }
  return self;
}

-(instancetype)initWithRef:(Firebase *)ref sortDescriptors:(NSArray *)sortDescriptors {
    return [self initWithQuery:ref sortDescriptors:sortDescriptors predicate:nil];
}

-(instancetype)initWithQuery:(FQuery *)query sortDescriptors:(NSArray *)sortDescriptors {
    return [self initWithQuery:query sortDescriptors:sortDescriptors predicate:nil];
}

-(instancetype)initWithQuery:(FQuery *)query predicate:(NSPredicate *)predicate {
    return [self initWithQuery:query sortDescriptors:nil predicate:predicate];
}

-(instancetype)initWithQuery:(FQuery *)query
             sortDescriptors:(NSArray *)sortDescriptors
                   predicate:(NSPredicate *)predicate {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.snapshots = [NSMutableArray array];
    self.query = query;
    self.sortDescriptors = sortDescriptors;
    self.predicate = predicate;
    
    [self initListeners];
    
    return self;
}

#pragma mark -
#pragma mark Memory management methods

- (void)dealloc {
    [self.query removeObserverWithHandle:_addHandle];
    [self.query removeObserverWithHandle:_changeHandle];
    [self.query removeObserverWithHandle:_removeHandle];
    [self.query removeObserverWithHandle:_moveHandle];
}

#pragma mark -
#pragma mark Private API methods

- (void)initListeners {
    [self initAddListener];
    [self initChangeListener];
    [self initRemoveListener];
    [self initMoveListener];
}

- (void)initAddListener {
    _addHandle = [self.query observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        if (self.predicate && ![self.predicate evaluateWithObject:snapshot]) {
            return;
        }
        
        NSUInteger index = [self insertionIndexForSnapshot:snapshot];
        
        [self.snapshots insertObject:snapshot atIndex:index];
        
        [self.delegate childAdded:snapshot atIndex:index];
    }];
}

- (void)initChangeListener {
    _changeHandle = [self.query observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        NSUInteger startingIndex = [self indexOfObject:snapshot];
        
        if (startingIndex != NSNotFound) {
            [self.snapshots removeObjectAtIndex:startingIndex];
            
            if (self.predicate && ![self.predicate evaluateWithObject:snapshot]) {
                [self.delegate childRemoved:snapshot atIndex:startingIndex];
                return;
            }
        }
        
        NSUInteger newSortedIndex = [self insertionIndexForSnapshot:snapshot];
        
        [self.snapshots insertObject:snapshot atIndex:newSortedIndex];
        if (startingIndex == NSNotFound) {
            [self.delegate childAdded:snapshot atIndex:newSortedIndex];
        } else if (newSortedIndex == startingIndex) {
            [self.delegate childChanged:snapshot atIndex:startingIndex];
        } else {
            [self.delegate childMoved:snapshot fromIndex:startingIndex toIndex:newSortedIndex];
        }
    }];
}

- (void)initRemoveListener {
    _removeHandle = [self.query observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        NSUInteger index = [self indexOfObject:snapshot];
        
        if (index == NSNotFound) {
            return;
        }
        
        [self.snapshots removeObjectAtIndex:index];
        
        [self.delegate childRemoved:snapshot atIndex:index];
    }];
}

- (void)initMoveListener {
    _moveHandle = [self.query observeEventType:FEventTypeChildMoved withBlock:^(FDataSnapshot *snapshot) {
        NSUInteger startingIndex = [self indexOfObject:snapshot];
        
        if (startingIndex != NSNotFound) {
            [self.snapshots removeObjectAtIndex:startingIndex];
            
            if (self.predicate && ![self.predicate evaluateWithObject:snapshot]) {
                [self.delegate childRemoved:snapshot atIndex:startingIndex];
                return;
            }
        }
        
        NSUInteger newSortedIndex = [self insertionIndexForSnapshot:snapshot];
        
        [self.snapshots insertObject:snapshot atIndex:newSortedIndex];
        if (startingIndex == NSNotFound) {
            [self.delegate childAdded:snapshot atIndex:newSortedIndex];
        } else if (newSortedIndex == startingIndex) {
            [self.delegate childChanged:snapshot atIndex:startingIndex];
        } else {
            [self.delegate childMoved:snapshot fromIndex:startingIndex toIndex:newSortedIndex];
        }
    }];
}

#pragma mark -
#pragma mark Searching Methods

- (NSUInteger)indexForKey:(NSString *)key {
  if (!key) return -1;

  for (NSUInteger index = 0; index < [self.snapshots count]; index++) {
    if ([key isEqualToString:[(FDataSnapshot *)[self.snapshots
                                 objectAtIndex:index] key]]) {
      return index;
    }
  }

  NSString *errorReason =
      [NSString stringWithFormat:@"Key \"%@\" not found in FirebaseArray %@",
                                 key, self.snapshots];
  @throw [NSException exceptionWithName:@"FirebaseArrayKeyNotFoundException"
                                 reason:errorReason
                               userInfo:@{
                                 @"Key" : key,
                                 @"Array" : self.snapshots
                               }];
}

-(NSUInteger)indexOfObject:(FDataSnapshot *)snapshot {
    return [self.snapshots indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(FDataSnapshot * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL result = [snapshot.key isEqualToString:obj.key];
        if (result) {
            *stop = YES;
        }
        return result;
    }];
}

- (NSUInteger)insertionIndexForSnapshot:(FDataSnapshot *)snapshot {
    if (!self.snapshots.count) {
        return 0;
    }
    return [self.snapshots indexOfObject:snapshot
                           inSortedRange:NSMakeRange(0, self.snapshots.count)
                                 options:
            NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual
                         usingComparator:[self comparator]];
}

- (NSComparator)comparator {
    if (self.sortDescriptors.count) {
        return ^(FDataSnapshot * obj1, FDataSnapshot * obj2) {
            if ([obj1.key isEqualToString:obj2.key]) {
                return NSOrderedSame;
            }
            
            NSComparisonResult result = NSOrderedSame;
            for (NSSortDescriptor * sortDescriptor in self.sortDescriptors) {
                result = [sortDescriptor compareObject:obj1 toObject:obj2];
                if (result != NSOrderedSame) {
                    break;
                }
            }
            return result;
        };
    }
    return ^(FDataSnapshot * obj1, FDataSnapshot * obj2) {
        return [obj1.key compare:obj2.key];
    };
}

#pragma mark -
#pragma mark Public API methods

- (NSUInteger)count {
  return [self.snapshots count];
}

- (FDataSnapshot *)objectAtIndex:(NSUInteger)index {
  return (FDataSnapshot *)[self.snapshots objectAtIndex:index];
}

- (Firebase *)refForIndex:(NSUInteger)index {
  return [(FDataSnapshot *)[self.snapshots objectAtIndex:index] ref];
}

@end
