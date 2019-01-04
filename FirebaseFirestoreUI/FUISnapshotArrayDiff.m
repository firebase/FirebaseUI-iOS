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

#import <FirebaseFirestore/FirebaseFirestore.h>

#import "FUISnapshotArrayDiff.h"

@implementation FUISnapshotArrayDiff

- (instancetype)initWithInitialArray:(NSArray *)initialArray resultArray:(NSArray *)resultArray {
  self = [super init];
  if (self != nil) {
    _initial = [initialArray copy];
    _result = [resultArray copy];
    [self buildFastDiffs];
  }
  return self;
}

- (instancetype)initWithInitialArray:(NSArray<FIRDocumentSnapshot *> *)initial
                         resultArray:(NSArray<FIRDocumentSnapshot *> *)result
                     documentChanges:(NSArray<FIRDocumentChange *> *)documentChanges {
  // TODO(morganchen): this needs to be tested with valid documentChange arrays from Firestore.
  self = [super init];
  if (self != nil) {
    _initial = [initial copy];
    _result = [result copy];
    [self buildDiffsFromDocumentChanges:documentChanges];
  }
  return self;
}

// Builds a fast (linear), non-minimal diff between the two collections of
// document snapshots. This diff may include some spurious moves, but should not
// violate any UIKit expectations for cell updates in table or collection views.
// It should not include any unnecessary adds, deletes, or reloads/changes.
- (void)buildFastDiffs {
  NSMutableDictionary<NSString *, NSNumber *> *oldIndexes =
      [NSMutableDictionary dictionaryWithCapacity:_initial.count];
  NSMutableDictionary<NSString *, NSNumber *> *newIndexes =
      [NSMutableDictionary dictionaryWithCapacity:_result.count];

  NSArray<FIRDocumentSnapshot *> *initial = _initial;
  NSArray<FIRDocumentSnapshot *> *result = _result;

  for (NSInteger i = 0; i < initial.count; i++) {
    oldIndexes[initial[i].documentID] = @(i);
  }
  for (NSInteger i = 0; i < result.count; i++) {
    newIndexes[result[i].documentID] = @(i);
  }

  // This set is used to look up the index of deletions later on.
  NSMutableOrderedSet<NSNumber *> *deletedIndexes = [NSMutableOrderedSet orderedSet];
  NSMutableOrderedSet<FIRDocumentSnapshot *> *deletedObjects = [NSMutableOrderedSet orderedSet];

  NSMutableArray<NSNumber *> *insertedIndexes = [NSMutableArray array];
  NSMutableArray<FIRDocumentSnapshot *> *insertedObjects = [NSMutableArray array];

  NSMutableArray<NSNumber *> *changedIndexes = [NSMutableArray array];
  NSMutableArray<FIRDocumentSnapshot *> *changedObjects = [NSMutableArray array];

  NSMutableArray<NSNumber *> *movedInitialIndexes = [NSMutableArray array];
  NSMutableArray<NSNumber *> *movedResultIndexes = [NSMutableArray array];
  NSMutableArray<FIRDocumentSnapshot *> *movedObjects = [NSMutableArray array];

  // Loop through the collections, building diff information as we go.
  // This is simpler than some other diff agorithms because documentIDs are guaranteed
  // to be unique, so we can't have multiple versions of the same document in a
  // collection. Here's the observations we're making:
  //
  // 1. If the document is unchanged and its start and end indexes are the same, ignore the
  //    document.
  // 2. If the document is different in the initial and result arrays but the documentID
  //    is the same, then the document was changed (and should be reloaded).
  // 3. If the document did not exist in the initial array, this corresponds to an added object.
  // 4. If the document did not exist in the result array, this corresponds to a deleted object.
  // 5. If an add and delete occurred at the same index, this corresponds to a changed object.
  // 6. If the document exists in both arrays with differing indexes, this corresponds to a moved
  //    object.
  // 7. If the document exists in both arrays with differing indexes and was also changed,
  //    this should be modeled as a delete and then an add.
  for (NSInteger i = 0; i < initial.count; i++) {
    NSString *key = initial[i].documentID;
    FIRDocumentSnapshot *_Nonnull oldDocument = initial[i];
    FIRDocumentSnapshot *_Nullable newDocument =
        newIndexes[key] != nil ? result[newIndexes[key].integerValue] : nil;
    BOOL changed = NO;
    BOOL moved = NO;

    if (newDocument == nil) {
      [deletedIndexes addObject:oldIndexes[key]];
      [deletedObjects addObject:oldDocument];
    } else {
      changed = ![newDocument isEqual:oldDocument];
      moved = ![oldIndexes[key] isEqualToNumber:newIndexes[key]];

      if (!changed && !moved) {
        continue;
      }

      if (changed && !moved) {
        [changedIndexes addObject:oldIndexes[key]];
        [changedObjects addObject:newDocument];
      }

      if (!changed && moved) {
        NSNumber *oldIndex = oldIndexes[key];
        NSNumber *newIndex = newIndexes[key];
        [movedInitialIndexes addObject:oldIndex];
        [movedResultIndexes addObject:newIndex];
        [movedObjects addObject:oldDocument];
      }

      if (changed && moved) {
        NSNumber *oldIndex = oldIndexes[key];
        NSNumber *newIndex = newIndexes[key];

        [deletedIndexes addObject:oldIndex];
        [deletedObjects addObject:oldDocument];

        [insertedIndexes addObject:newIndex];
        [insertedObjects addObject:newDocument];
      }
    }
  }

  // Only process insertions and changes as a result of insertions and deletions to the same
  // index in this loop.
  for (NSInteger i = 0; i < result.count; i++) {
    FIRDocumentSnapshot *newDocument = result[i];
    NSString *key = newDocument.documentID;
    if (oldIndexes[key] != nil) { continue; }

    NSNumber *newIndex = newIndexes[key];
    if ([deletedIndexes containsObject:newIndex]) {
      FIRDocumentSnapshot *oldDocument = initial[newIndexes[key].integerValue];
      [deletedIndexes removeObject:newIndex];
      [deletedObjects removeObject:oldDocument];

      [changedIndexes addObject:newIndex];
      [changedObjects addObject:newDocument];
    } else {
      [insertedIndexes addObject:newIndex];
      [insertedObjects addObject:newDocument];
    }
  }

  _deletedIndexes = [deletedIndexes array];
  _deletedObjects = [deletedObjects array];

  _insertedIndexes = [insertedIndexes copy];
  _insertedObjects = [insertedObjects copy];

  _changedIndexes = [changedIndexes copy];
  _changedObjects = [changedObjects copy];

  _movedInitialIndexes = [movedInitialIndexes copy];
  _movedResultIndexes = [movedResultIndexes copy];
  _movedObjects = [movedObjects copy];
}

- (void)buildDiffsFromDocumentChanges:(NSArray<FIRDocumentChange *> *)documentChanges {
  NSMutableDictionary<NSString *, NSNumber *> *oldIndexes =
      [NSMutableDictionary dictionaryWithCapacity:_initial.count];
  NSMutableDictionary<NSString *, NSNumber *> *newIndexes =
      [NSMutableDictionary dictionaryWithCapacity:_result.count];

  NSArray<FIRDocumentSnapshot *> *initial = _initial;
  NSArray<FIRDocumentSnapshot *> *result = _result;

  // Ignore the FIRDocumentChange indexing, since we do our own
  for (NSInteger i = 0; i < initial.count; i++) {
    oldIndexes[initial[i].documentID] = @(i);
  }
  for (NSInteger i = 0; i < result.count; i++) {
    newIndexes[result[i].documentID] = @(i);
  }

  NSMutableArray<NSNumber *> *deletedIndexes = [NSMutableArray array];
  NSMutableArray *deletedObjects = [NSMutableArray array];

  NSMutableArray<NSNumber *> *insertedIndexes = [NSMutableArray array];
  NSMutableArray *insertedObjects = [NSMutableArray array];

  NSMutableArray<NSNumber *> *changedIndexes = [NSMutableArray array];
  NSMutableArray *changedObjects = [NSMutableArray array];

  NSMutableArray<NSNumber *> *movedInitialIndexes = [NSMutableArray array];
  NSMutableArray<NSNumber *> *movedResultIndexes = [NSMutableArray array];
  NSMutableArray *movedObjects = [NSMutableArray array];

  NSMutableSet<FIRDocumentSnapshot *> *movedSnapshots = [NSMutableSet set];

  for (FIRDocumentChange *change in documentChanges) {
    FIRDocumentSnapshot *snapshot = change.document;
    NSNumber *oldIndex = oldIndexes[snapshot.documentID];
    NSNumber *newIndex = newIndexes[snapshot.documentID];
    if (oldIndex == nil && newIndex == nil) { continue; }
    switch (change.type) {
      case FIRDocumentChangeTypeRemoved:
        // Ignore deletions that weren't in the original array.
        if (oldIndex == nil) { continue; }
        // Deletions that were then added again should be counted as moves.
        if (newIndex != nil) {
          [movedInitialIndexes addObject:oldIndex];
          [movedResultIndexes addObject:newIndex];
          [movedObjects addObject:snapshot];

          // Keep track of which insertions we should ignore later.
          [movedSnapshots addObject:snapshot];
        } else {
          [deletedIndexes addObject:oldIndex];
          [deletedObjects addObject:snapshot];
        }
        continue;
      case FIRDocumentChangeTypeModified:
        // Don't try to reload changes that weren't in the initial and result arrays.
        if (newIndex == nil || oldIndex == nil) { continue; }
        // This should be counted as a move.
        if (![newIndex isEqualToNumber:oldIndex]) {
          [movedInitialIndexes addObject:oldIndex];
          [movedResultIndexes addObject:newIndex];
          [movedObjects addObject:snapshot];

          // Keep track of which insertions we should ignore later.
          [movedSnapshots addObject:snapshot];
        } else {
          [changedIndexes addObject:oldIndex];
          [changedObjects addObject:snapshot];
        }
        continue;
      case FIRDocumentChangeTypeAdded:
        // Ignore insertions that were later removed.
        if (newIndex == nil) { continue; }
        // Ignore insertions of previously removed items, since those are
        // counted as moves.
        if (oldIndex != nil) { continue; }
        // Ignore insertions that we consider moves.
        if ([movedSnapshots containsObject:snapshot]) { continue; }
        [insertedIndexes addObject:newIndex];
        [insertedObjects addObject:snapshot];
        continue;
    }
  }

  _deletedIndexes = [deletedIndexes copy];
  _deletedObjects = [deletedObjects copy];

  _insertedIndexes = [insertedIndexes copy];
  _insertedObjects = [insertedObjects copy];

  _changedIndexes = [changedIndexes copy];
  _changedObjects = [changedObjects copy];

  _movedInitialIndexes = [movedInitialIndexes copy];
  _movedResultIndexes = [movedResultIndexes copy];
  _movedObjects = [movedObjects copy];
}

- (NSString *)description {
  NSMutableString *result =
      [NSMutableString stringWithFormat:@"<%@: %p ", NSStringFromClass([self class]), self];

  NSMutableString *deleted = [@"Deleted: (\n" mutableCopy];
  for (NSInteger i = 0; i < _deletedIndexes.count; i++) {
    NSNumber *index = _deletedIndexes[i];
    id object = _deletedObjects[i];
    [deleted appendFormat:@"  %li, %@\n", (long)index.integerValue, object];
  }
  [deleted appendString:@")\n"];

  [result appendString:deleted];

  NSMutableString *moved = [@"Moved: (\n" mutableCopy];
  for (NSInteger i = 0; i < _movedInitialIndexes.count; i++) {
    NSNumber *initial = _movedInitialIndexes[i];
    NSNumber *final = _movedResultIndexes[i];
    id object = _movedObjects[i];
    [moved appendFormat:@"  %li -> %li, %@\n",
        (long)initial.integerValue, (long)final.integerValue, object];
  }
  [moved appendString:@")\n"];

  [result appendString:moved];

  NSMutableString *changed = [@"Changed: (\n" mutableCopy];
  for (NSInteger i = 0; i < _changedIndexes.count; i++) {
    NSNumber *index = _changedIndexes[i];
    id object = _changedObjects[i];
    [changed appendFormat:@"  %li, %@\n", (long)index.integerValue, object];
  }
  [changed appendString:@")\n"];

  [result appendString:changed];

  NSMutableString *inserted = [@"Inserted: (\n" mutableCopy];
  for (NSInteger i = 0; i < _insertedIndexes.count; i++) {
    NSNumber *index = _insertedIndexes[i];
    id object = _insertedObjects[i];
    [inserted appendFormat:@"  %li, %@\n", (long)index.integerValue, object];
  }
  [inserted appendString:@")\n"];

  [result appendString:inserted];
  [result appendString:@">"];

  return [result copy];
}

@end
