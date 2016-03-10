//
//  FirebaseSortedData.m
//  FirebaseUI
//
//  Created by Zoe Van Brunt on 11/25/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import "FirebaseSortedData.h"

#import "FirebaseSet.h"

#import <UIKit/UITableView.h>

#import <Firebase/FDataSnapshot.h>

static NSString * singleSectionKey = @"singleSectionKey";

@interface FSDMutableSortedDictionaryOfArrays : NSObject

- (instancetype)initWithSortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors
                   keysOrderedAscending:(BOOL)keysOrderedAscending
                uniqueIdentifierKeyPath:(NSString *)uniqueIdentifierKeyPath;
- (NSArray *)orderedKeys;
- (NSUInteger)indexOfKey:(id)key;
- (NSUInteger)insertionIndexForKey:(id)key;
- (NSIndexPath *)insertObject:(id)object forKey:(id)key;
- (NSIndexPath *)removeObject:(id)object;
- (void)removeKeyAtIndex:(NSUInteger)index;
- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)indexOfObject:(id)object forKey:(id)key;
- (NSIndexPath *)indexPathOfObject:(id)object;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)allSortedObjects;
- (NSArray *)arrayAtIndex:(NSUInteger)index;
- (void)addSortedArray:(NSArray *)array forKey:(id)key;

@end

@interface FDataSnapshot (FirebaseSetObject) <FirebaseSetObject>
@end
@implementation FDataSnapshot (FirebaseSetObject)
@end

@interface FirebaseSortedData ()

@property (nonatomic, strong) FSDMutableSortedDictionaryOfArrays * table;

@end

@implementation FirebaseSortedData

#pragma mark Initializer Methods

- (instancetype)initWithRef:(Firebase *)ref;
{
    FirebaseSet * fSet = [[FirebaseSet alloc] initWithRef:ref];
    
    return [self initWithFirebaseSet:fSet];
}


- (instancetype)initWithFirebaseSet:(FirebaseSet *)firebaseSet;
{
    self = [self init];
    
    [self setFirebaseSet:firebaseSet];
    
    return self;
}

- (instancetype)init;
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)dealloc;
{
    [self.firebaseSet removeDelegate:self];
}


#pragma mark Public API Methods

- (void)setFirebaseSet:(FirebaseSet *)firebaseSet;
{
    _firebaseSet = firebaseSet;
    [_firebaseSet addDelegate:self];
    
    [self initializeSortedObjects];
}

- (void)setPredicate:(NSPredicate *)predicate;
{
    _predicate = predicate;
    
    if (self.firebaseSet) {
        [self initializeSortedObjects];
    }
}

- (void)setSortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors;
{
    _sortDescriptors = sortDescriptors;
    
    if (self.firebaseSet) {
        [self initializeSortedObjects];
    }
}

- (void)setSectionKeyPath:(NSString *)sectionKeyPath;
{
    _sectionKeyPath = sectionKeyPath;
    
    if (self.firebaseSet) {
        [self initializeSortedObjects];
    }
}

- (void)setSectionsOrderedAscending:(BOOL)sectionsOrderedAscending;
{
    _sectionsOrderedAscending = sectionsOrderedAscending;
    
    if (self.firebaseSet) {
        [self initializeSortedObjects];
    }
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
{
    return [self.table objectAtIndexPath:indexPath];
}


- (NSArray<id> *)sortedObjects;
{
    return [self.table allSortedObjects];
}


- (NSArray *)sectionAtIndex:(NSUInteger)sectionIndex;
{
    return [self.table arrayAtIndex:sectionIndex];
}

- (NSArray<id> *)sectionValues;
{
    if (self.sectionKeyPath) {
        return [self.table orderedKeys];
    }
    return nil;
}


- (NSUInteger)count;
{
    return [self.table allSortedObjects].count;
}


- (NSUInteger)numberOfObjectsInSection:(NSUInteger)sectionIndex;
{
    return [self sectionAtIndex:sectionIndex].count;
}


- (NSUInteger)numberOfSections;
{
    return [self.table orderedKeys].count;
}

#pragma mark Private API Methods

- (void)initializeSortedObjects;
{
    self.table = [[FSDMutableSortedDictionaryOfArrays alloc] initWithSortDescriptors:[self aggregateSortDescriptors]
                                                                keysOrderedAscending:self.sectionsOrderedAscending
                                                             uniqueIdentifierKeyPath:@"key"];
    
    NSSet * objects = [self.firebaseSet objects];
    
    if (!objects.count) {
        return;
    }
    
    NSPredicate * predicate = self.predicate;
    
    if (predicate) {
        objects = [objects filteredSetUsingPredicate:predicate];
    }
    
    NSArray <NSSortDescriptor *> * sortDescriptors = [self aggregateSortDescriptors];
    
    if (self.sectionKeyPath) {
        NSSortDescriptor * sectionSort =
        [NSSortDescriptor sortDescriptorWithKey:self.sectionKeyPath
                                      ascending:self.sectionsOrderedAscending];
        
        sortDescriptors = [@[sectionSort] arrayByAddingObjectsFromArray:sortDescriptors];
        
        NSSet * sectionValues = [objects valueForKey:self.sectionKeyPath];
        
        for (id sectionValue in sectionValues) {
            NSExpression * lhs = [NSExpression expressionForKeyPath:self.sectionKeyPath];
            NSExpression * rhs = [NSExpression expressionForConstantValue:sectionValue];
            NSPredicate * sectionPredicate =
            [NSComparisonPredicate predicateWithLeftExpression:lhs
                                               rightExpression:rhs
                                                      modifier:NSDirectPredicateModifier
                                                          type:NSEqualToPredicateOperatorType
                                                       options:0];
            NSSet * filteredSet = [objects filteredSetUsingPredicate:sectionPredicate];
            NSArray * sortedSection = [filteredSet sortedArrayUsingDescriptors:sortDescriptors];
            
            [self.table addSortedArray:sortedSection forKey:sectionValue];
        }
    } else {
        NSArray * sortedObjects = [objects sortedArrayUsingDescriptors:sortDescriptors];
        
        [self.table addSortedArray:sortedObjects forKey:singleSectionKey];
    }
    
    [self.delegate reload];
}

- (NSArray <NSSortDescriptor *> *)aggregateSortDescriptors;
{
    NSArray * sortDescriptors = [NSArray arrayWithArray:self.sortDescriptors];
    
    NSSortDescriptor * keyDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    sortDescriptors = [sortDescriptors arrayByAddingObject:keyDescriptor];
    
    return sortDescriptors;
}

#pragma mark FirebaseSetDelegate

- (void)firebaseSet:(FirebaseSet *)firebaseSet added:(NSObject <FirebaseSetObject> *)obj;
{
    if (self.predicate && ![self.predicate evaluateWithObject:obj]) {
        return;
    }
    
    id sectionValue =
    self.sectionKeyPath? [obj valueForKeyPath:self.sectionKeyPath] : singleSectionKey;
    
    NSIndexPath * path = [self.table insertObject:obj forKey:sectionValue];
    
    if ([self numberOfObjectsInSection:path.section] == 1) {
        [self.delegate sectionAddedAtSectionIndex:path.section];
    } else {
        [self.delegate childAdded:obj atIndexPath:path];
    }
}

- (void)firebaseSet:(FirebaseSet *)firebaseSet removed:(NSObject <FirebaseSetObject> *)obj;
{
    NSIndexPath * path = [self.table removeObject:obj];
    
    if (!path) {
        return;
    }
    
    if ([self numberOfObjectsInSection:path.section] == 0) {
        [self.table removeKeyAtIndex:path.section];
        [self.delegate sectionRemovedAtSectionIndex:path.section];
    } else {
        [self.delegate childRemoved:obj atIndexPath:path];
    }
}

- (void)firebaseSet:(FirebaseSet *)firebaseSet changed:(NSObject<FirebaseSetObject> *)changedObject;
{
    NSIndexPath * startingPath = [self.table indexPathOfObject:changedObject];
    
    if (self.predicate) {
        BOOL objectPassesPredicate = [self.predicate evaluateWithObject:changedObject];
        
        if (!startingPath && !objectPassesPredicate) {
            return;
        }
        if (!objectPassesPredicate) {
            [self firebaseSet:firebaseSet removed:changedObject];
            return;
        }
        if (!startingPath) {
            [self firebaseSet:firebaseSet added:changedObject];
            return;
        }
    }
    
    
    [self.table removeObjectAtIndexPath:startingPath];
    
    BOOL removeSection = [self numberOfObjectsInSection:startingPath.section] == 0;
    if (removeSection) {
        [self.table removeKeyAtIndex:startingPath.section];
    }
    
    NSIndexPath * endingPath;
    if (self.sectionKeyPath) {
        id endingSectionValue = [changedObject valueForKeyPath:self.sectionKeyPath];
        endingPath = [self.table insertObject:changedObject forKey:endingSectionValue];
    } else {
        endingPath = [self.table insertObject:changedObject forKey:singleSectionKey];
    }
    
    
    if ([startingPath compare:endingPath] == NSOrderedSame) {
        [self.delegate childChanged:changedObject atIndexPath:endingPath];
        return;
    }
    
    [self.delegate beginUpdates];
    if (removeSection) {
        [self.delegate sectionRemovedAtSectionIndex:startingPath.section];
    } else {
        [self.delegate childRemoved:changedObject atIndexPath:startingPath];
    }
    
    if ([self numberOfObjectsInSection:endingPath.section] == 1) {
        [self.delegate sectionAddedAtSectionIndex:endingPath.section];
    } else {
        [self.delegate childAdded:changedObject atIndexPath:endingPath];
    }
    [self.delegate endUpdates];
}

@end

@implementation FSDMutableSortedDictionaryOfArrays {
    NSMutableDictionary <id, NSMutableArray *> * _dictionary;
    NSComparisonResult (^_comparator)(id  _Nonnull obj1, id  _Nonnull obj2);
    NSComparisonResult (^_arrayComparator)(id  _Nonnull obj1, id  _Nonnull obj2);
    NSString * _uniqueIdentifierKeyPath;
}

- (instancetype)initWithSortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors
                   keysOrderedAscending:(BOOL)keysOrderedAscending
                uniqueIdentifierKeyPath:(NSString *)uniqueIdentifierKeyPath;
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _dictionary = [NSMutableDictionary dictionary];
    
    _comparator = ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (keysOrderedAscending)
        { return [obj1 compare:obj2]; }
        else
        { return [obj2 compare:obj1]; }
    };
    
    _arrayComparator = ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSArray * sort = sortDescriptors;
        
        NSComparisonResult result = NSOrderedSame;
        for (NSSortDescriptor * sortDescriptor in sort) {
            result = [sortDescriptor compareObject:obj1 toObject:obj2];
            if (result != NSOrderedSame) { break; }
        }
        return result;
    };
    
    _uniqueIdentifierKeyPath = uniqueIdentifierKeyPath;
    
    return self;
}

- (NSArray *)orderedKeys;
{
    return [_dictionary.allKeys sortedArrayWithOptions:NSSortConcurrent
                                       usingComparator:_comparator];
}

- (NSUInteger)indexOfKey:(id)key;
{
    return [[self orderedKeys] indexOfObject:key];
}

- (NSUInteger)insertionIndexForKey:(id)key;
{
    NSArray * orderedKeys = [self orderedKeys];
    return [orderedKeys indexOfObject:key
                        inSortedRange:(NSRange){0, orderedKeys.count}
                              options:NSBinarySearchingInsertionIndex
                      usingComparator:_comparator];
}

- (NSIndexPath *)insertObject:(id)object forKey:(id)key;
{
    NSUInteger row;
    NSUInteger section;
    
    if ([_dictionary.allKeys containsObject:key]) {
        NSMutableArray * array = _dictionary[key];
        NSUInteger index = [array indexOfObject:object
                                  inSortedRange:(NSRange){0, array.count}
                                        options:NSBinarySearchingInsertionIndex
                                usingComparator:_arrayComparator];
        [array insertObject:object atIndex:index];
        row = index;
    } else {
        NSMutableArray * array = [NSMutableArray arrayWithObject:object];
        _dictionary[key] = array;
        row = 0;
    }
    
    section = [self indexOfKey:key];
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSIndexPath *)removeObject:(id)object;
{
    NSIndexPath * indexPath = [self indexPathOfObject:object];
    
    if (!indexPath) {
        return nil;
    }
    
    [self removeObjectAtIndexPath:indexPath];
    
    return indexPath;
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath;
{
    id key = [self orderedKeys][indexPath.section];
    
    NSMutableArray * array = _dictionary[key];
    
    [array removeObjectAtIndex:indexPath.row];
}

- (void)removeKeyAtIndex:(NSUInteger)index;
{
    id key = self.orderedKeys[index];
    
    [_dictionary removeObjectForKey:key];
}

- (NSUInteger)indexOfObject:(id)object forKey:(id)key;
{
    NSMutableArray * array = _dictionary[key];
    
    return [self indexOfObject:object inArray:array];
}

- (NSUInteger)indexOfObject:(id)object inArray:(NSArray *)array {
    
    id uid = [object valueForKeyPath:_uniqueIdentifierKeyPath];
    
    return [array indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [[obj valueForKeyPath:_uniqueIdentifierKeyPath] compare:uid] == NSOrderedSame;
    }];
}

- (NSIndexPath *)indexPathOfObject:(id)object;
{
    __block id key;
    __block NSUInteger row = NSNotFound;
    [_dictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull blockKey, NSMutableArray * _Nonnull array, BOOL * _Nonnull stop) {
        NSUInteger index = [self indexOfObject:object inArray:array];
        if (index != NSNotFound) {
            key = blockKey;
            row = index;
            *stop = YES;
        }
    }];
    
    if (row == NSNotFound) {
        return nil;
    }
    
    NSUInteger section = [self indexOfKey:key];
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
{
    id key = [self orderedKeys][indexPath.section];
    
    return _dictionary[key][indexPath.row];
}

- (NSArray *)allSortedObjects;
{
    NSMutableArray * array = [NSMutableArray array];
    for (id key in [self orderedKeys]) {
        [array addObjectsFromArray:_dictionary[key]];
    }
    return array;
}

- (NSArray *)arrayAtIndex:(NSUInteger)index;
{
    id key = [self orderedKeys][index];
    
    return _dictionary[key];
}

- (void)addSortedArray:(NSArray *)array forKey:(id)key;
{
    _dictionary[key] = [NSMutableArray arrayWithArray:array];
}

@end
