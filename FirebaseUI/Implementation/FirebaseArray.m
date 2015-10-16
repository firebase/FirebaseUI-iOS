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

#import <UIKit/UITableView.h>

#import "FirebaseArray.h"

@implementation FirebaseArray {
    BOOL _initStarted;
    BOOL _initialized;
    FirebaseHandle _addHandle;
    FirebaseHandle _changeHandle;
    FirebaseHandle _removeHandle;
    FirebaseHandle _moveHandle;
    FirebaseHandle _valueHandle;
}

#pragma mark -
#pragma mark Initializer methods

- (instancetype)initWithRef:(Firebase *)ref {
  return [self initWithQuery:ref];
}

- (instancetype)initWithQuery:(FQuery *)query {
  self = [super init];
  if (self) {
      self.sectionValues = [NSMutableOrderedSet orderedSet];
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
    self.sectionValues = [NSMutableOrderedSet orderedSet];
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
    [self.query removeObserverWithHandle:_valueHandle];
}

#pragma mark -
#pragma mark Private API methods

- (void)initListeners {
    [self initAddListener];
    [self initChangeListener];
    [self initRemoveListener];
    [self initMoveListener];
    [self initValueListener];
}

- (void)initValueListener {
    _valueHandle = [self.query observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (_initialized) {
            return;
        }
        
        _initialized = YES;
        if (self.sectionKeyPath) {
            NSUInteger count = self.sectionValues.count;
            
            NSIndexSet * sections = [NSIndexSet
                                     indexSetWithIndexesInRange:NSMakeRange(0, count)];
            
            [self.delegate sectionsAddedAtIndexes:sections];
        } else {
            [self.delegate sectionsAddedAtIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
        [self.delegate endUpdates];
    }];
}

- (void)initAddListener {
    _addHandle = [self.query observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        if (!_initialized && !_initStarted) {
            _initStarted = YES;
            [self.delegate beginUpdates];
        }
        if (self.predicate && ![self.predicate evaluateWithObject:snapshot]) {
            return;
        }
        
        NSUInteger index = [self insertionIndexForSnapshot:snapshot];
        
        [self.snapshots insertObject:snapshot atIndex:index];
        
        if (self.sectionKeyPath) {
            id sectionKeyValue = [snapshot valueForKeyPath:self.sectionKeyPath];
            
            if (![self.sectionValues containsObject:sectionKeyValue]) {
                NSUInteger sectionIndex =
                [self.sectionValues indexOfObject:sectionKeyValue
                                    inSortedRange:NSMakeRange(0, self.sectionValues.count)
                                          options:
                 NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual
                                  usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                      return self.sectionsOrderedAscending? [obj1 compare:obj2] :[obj2 compare:obj1];
                                  }];
                
                [self.sectionValues insertObject:sectionKeyValue atIndex:sectionIndex];
                
                if (_initialized) [self.delegate sectionAddedAtSectionIndex:sectionIndex];
                
                return;
            }
        }
        
        NSIndexPath * indexPath = [self indexPathOfObject:snapshot];
        
        if (_initialized) [self.delegate childAdded:snapshot atIndexPath:indexPath];
    }];
}

- (void)initRemoveListener {
    _removeHandle = [self.query observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        if (!_initialized && !_initStarted) {
            _initStarted = YES;
            [self.delegate beginUpdates];
        }
        NSUInteger index = [self indexInSnapshotsForKey:snapshot.key];

        if (index == NSNotFound) {
            return;
        }
        
        NSIndexPath * indexPath = [self indexPathOfObject:snapshot];

        [self.snapshots removeObjectAtIndex:index];
        
        if (self.sectionKeyPath && ![self sectionAtIndex:indexPath.section].count) {
            [self.sectionValues removeObjectAtIndex:indexPath.section];
            
            if (_initialized) [self.delegate sectionRemovedAtSectionIndex:indexPath.section];
        } else {
            if (_initialized) [self.delegate childRemoved:snapshot atIndexPath:indexPath];
        }
    }];
}

- (void)handleChange:(FDataSnapshot *)snapshot {
    if (!_initialized && !_initStarted) {
        _initStarted = YES;
        [self.delegate beginUpdates];
    }
    
    NSUInteger startingIndexInSnapshots = [self indexInSnapshotsForKey:snapshot.key];
    
    NSIndexPath * startingIndexPath = [self indexPathForKey:snapshot.key];
    
    id startingSectionKeyValue;
    id newSectionKeyValue;
    
    BOOL sectionRemoved = NO;
    NSUInteger startingSectionIndex = 0;
    FDataSnapshot * startingSnapshot;
    
    if (startingIndexInSnapshots != NSNotFound) {
        startingSnapshot = self.snapshots[startingIndexInSnapshots];
        
        [self.snapshots removeObjectAtIndex:startingIndexInSnapshots];
        
        if (self.sectionKeyPath) {
            startingSectionKeyValue = [startingSnapshot valueForKeyPath:self.sectionKeyPath];
            
            startingSectionIndex = [self.sectionValues indexOfObject:startingSectionKeyValue];
            
            newSectionKeyValue = [snapshot valueForKeyPath:self.sectionKeyPath];
            
            if (![startingSectionKeyValue isEqual:newSectionKeyValue] &&
                ![self sectionAtIndex:startingSectionIndex].count) {
                
                [self.sectionValues removeObjectAtIndex:startingSectionIndex];
                
                sectionRemoved = YES;
            }
        }
    }
    
    
    if (self.predicate && ![self.predicate evaluateWithObject:snapshot]) {
        return;
    }
    
    
    BOOL sectionInserted = NO;
    
    if (self.sectionKeyPath && ![self.sectionValues containsObject:newSectionKeyValue]) {
        NSUInteger newSectionIndex =
        [self.sectionValues indexOfObject:newSectionKeyValue
                            inSortedRange:NSMakeRange(0, self.sectionValues.count)
                                  options:
         NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual
                          usingComparator:^NSComparisonResult(id obj1, id obj2) {
                              return self.sectionsOrderedAscending? [obj1 compare:obj2] :[obj2 compare:obj1];
                          }];
        
        [self.sectionValues insertObject:newSectionKeyValue atIndex:newSectionIndex];
        
        sectionInserted = YES;
    }
    
    
    NSUInteger newSortedIndex = [self insertionIndexForSnapshot:snapshot];
    
    [self.snapshots insertObject:snapshot atIndex:newSortedIndex];
    
    NSIndexPath * newIndexPath = [self indexPathOfObject:snapshot];
    
    if (!_initialized) {
        return;
    }
    
    
    [self.delegate beginUpdates];
    if ([startingIndexPath compare:newIndexPath] == NSOrderedSame) {
        if (sectionInserted && sectionRemoved) {
            [self.delegate sectionRemovedAtSectionIndex:startingSectionIndex];
            [self.delegate sectionAddedAtSectionIndex:newIndexPath.section];
        } else if (sectionInserted) {
            [self.delegate childRemoved:startingSnapshot atIndexPath:startingIndexPath];
            [self.delegate sectionAddedAtSectionIndex:newIndexPath.section];
        } else if (sectionRemoved) {
            [self.delegate sectionRemovedAtSectionIndex:startingSectionIndex];
            [self.delegate childAdded:snapshot atIndexPath:newIndexPath];
        } else {
            [self.delegate childChanged:snapshot atIndexPath:newIndexPath];
        }
    } else {
        if (sectionInserted && sectionRemoved) {
            [self.delegate sectionRemovedAtSectionIndex:startingSectionIndex];
            [self.delegate sectionAddedAtSectionIndex:newIndexPath.section];
        } else if (sectionInserted) {
            [self.delegate childRemoved:startingSnapshot atIndexPath:startingIndexPath];
            [self.delegate sectionAddedAtSectionIndex:newIndexPath.section];
        } else if (sectionRemoved) {
            [self.delegate sectionRemovedAtSectionIndex:startingSectionIndex];
            [self.delegate childAdded:snapshot atIndexPath:newIndexPath];
        } else {
            [self.delegate childMoved:snapshot fromIndexPath:startingIndexPath toIndexPath:newIndexPath];
        }
    }
    [self.delegate endUpdates];
}

- (void)initChangeListener {
    _changeHandle = [self.query observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [self handleChange:snapshot];
    }];
}

- (void)initMoveListener {
    _moveHandle = [self.query observeEventType:FEventTypeChildMoved withBlock:^(FDataSnapshot *snapshot) {
        [self handleChange:snapshot];
    }];
}

#pragma mark -
#pragma mark Searching Methods

- (NSUInteger)indexInSnapshotsForKey:(NSString *)key {
    if (!key) return NSNotFound;
    
    NSUInteger index =
    [self.snapshots
     indexOfObjectWithOptions:NSEnumerationConcurrent
     passingTest:^BOOL(FDataSnapshot * obj, NSUInteger idx, BOOL * stop) {
         BOOL result = [key isEqualToString:obj.key];
         if (result) {
             *stop = YES;
         }
         return result;
     }];
    
    return index;
}

- (NSIndexPath *)indexPathForKey:(NSString *)key {
    if (!key) return [NSIndexPath indexPathForRow:NSNotFound inSection:NSNotFound];
    
    NSUInteger indexInSnapshots = [self indexInSnapshotsForKey:key];
    
    if (indexInSnapshots == NSNotFound) {
        return nil;
    }
    
    return [self indexPathOfObject:self.snapshots[indexInSnapshots]];
}

-(NSIndexPath *)indexPathOfObject:(FDataSnapshot *)snapshot {
    NSUInteger sectionIndex;
    
    if (self.sectionKeyPath) {
        id sectionKeyValue = [snapshot valueForKeyPath:self.sectionKeyPath];
        sectionIndex = [self.sectionValues indexOfObject:sectionKeyValue];
        
        if (sectionIndex == NSNotFound) {
            NSString *errorReason =
            [NSString stringWithFormat:@"Section \"%@\" not found in SectionValues %@",
             sectionKeyValue, self.sectionValues];
            @throw [NSException exceptionWithName:@"FirebaseArraySectionNotFoundException"
                                           reason:errorReason
                                         userInfo:@{
                                                    @"Section" : sectionKeyValue,
                                                    @"SectionValues" : self.sectionValues
                                                    }];
        }
    } else {
        sectionIndex = 0;
    }
    
    NSArray * section = [self sectionAtIndex:sectionIndex];
    NSUInteger rowIndex =
    [section
     indexOfObjectWithOptions:NSEnumerationConcurrent
     passingTest:^BOOL(FDataSnapshot * obj, NSUInteger idx, BOOL * stop) {
         BOOL result = [snapshot.key isEqualToString:obj.key];
         if (result) {
             *stop = YES;
         }
         return result;
     }];
    
    return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
}

- (NSArray *)sectionAtIndex:(NSUInteger)sectionIndex {
    NSString * sectionKeyPath = self.sectionKeyPath;
    
    if (!sectionKeyPath) {
        if (sectionIndex == 0) {
            return self.snapshots;
        } else {
            return [NSArray array];
        }
    }
    
    id sectionKeyValue = self.sectionValues[sectionIndex];
    
    NSUInteger firstIndex = [self.snapshots indexOfObject:sectionKeyValue
                                            inSortedRange:NSMakeRange(0, self.snapshots.count)
                                                  options:NSBinarySearchingFirstEqual
                                          usingComparator:^NSComparisonResult(id obj1,
                                                                              id obj2) {
                                              NSComparisonResult result;
                                              NSNumber * num1 = [obj1 isKindOfClass:[sectionKeyValue class]]? obj1 : [obj1 valueForKeyPath:sectionKeyPath];
                                              NSNumber * num2 = [obj2 isKindOfClass:[sectionKeyValue class]]? obj2 : [obj2 valueForKeyPath:sectionKeyPath];
                                              
                                              result = [num1 compare:num2];
                                              return self.sectionsOrderedAscending? result : result * -1L;
                                          }];
    if (firstIndex == NSNotFound) {
        return [NSArray array];
    }
    
    NSUInteger lastIndex = [self.snapshots indexOfObject:sectionKeyValue
                                           inSortedRange:NSMakeRange(0, self.snapshots.count)
                                                 options:NSBinarySearchingLastEqual
                                         usingComparator:^NSComparisonResult(id obj1,
                                                                             id obj2) {
                                             NSComparisonResult result;
                                             NSNumber * num1 = [obj1 isKindOfClass:[sectionKeyValue class]]? obj1 : [obj1 valueForKeyPath:sectionKeyPath];
                                             NSNumber * num2 = [obj2 isKindOfClass:[sectionKeyValue class]]? obj2 : [obj2 valueForKeyPath:sectionKeyPath];
                                             
                                             result = [num1 compare:num2];
                                             return self.sectionsOrderedAscending? result: result * -1L;
                                         }];
    
    NSRange sectionRange = NSMakeRange(firstIndex, lastIndex - firstIndex + 1);
    
    return [self.snapshots subarrayWithRange:sectionRange];
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
    NSArray * sortDescriptors = [NSArray array];
    if (self.sectionKeyPath) {
        sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:self.sectionKeyPath
                                                          ascending:self.sectionsOrderedAscending]];
    }
    if (self.sortDescriptors.count) {
        sortDescriptors = [sortDescriptors arrayByAddingObjectsFromArray:self.sortDescriptors];
    }
    
    if (sortDescriptors.count) {
        return ^(FDataSnapshot * obj1, FDataSnapshot * obj2) {
            NSArray * sort = sortDescriptors;
            
            if ([obj1.key isEqualToString:obj2.key]) {
                return NSOrderedSame;
            }
            
            NSComparisonResult result = NSOrderedSame;
            for (NSSortDescriptor * sortDescriptor in sort) {
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

-(NSUInteger)numberOfSections {
    if (!_initialized) {
        return 0;
    }
    if (self.sectionKeyPath) {
        return self.sectionValues.count;
    }
    return 1;
}

- (FDataSnapshot *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSArray * section = [self sectionAtIndex:indexPath.section];
    return section[indexPath.row];
}

- (Firebase *)refForIndexPath:(NSIndexPath *)indexPath {
    return [self objectAtIndexPath:indexPath].ref;
}

@end
