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

@import FirebaseDatabase;

@implementation FirebaseArray

#pragma mark -
#pragma mark Initializer methods

- (instancetype)initWithRef:(FIRDatabaseReference *)ref {
  return [self initWithQuery:ref];
}

- (instancetype)initWithQuery:(FIRDatabaseQuery *)query {
  self = [super init];
  if (self) {
    self.snapshots = [NSMutableArray array];
    self.query = query;

    [self initListeners];
  }
  return self;
}

#pragma mark -
#pragma mark Memory management methods

- (void)dealloc {
  // TODO: Consider keeping track of these and only removing them if they are
  // explicitly added here
  [self.query removeAllObservers];
}

#pragma mark -
#pragma mark Private API methods

- (void)initListeners {
  [self.query observeEventType:FIRDataEventTypeChildAdded
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger index = [self indexForKey:previousChildKey] + 1;

        [self.snapshots insertObject:snapshot atIndex:index];

        [self.delegate childAdded:snapshot atIndex:index];
      }
      withCancelBlock:^(NSError *error) {
        [self.delegate canceledWithError:error];
      }];

  [self.query observeEventType:FIRDataEventTypeChildChanged
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger index = [self indexForKey:snapshot.key];

        [self.snapshots replaceObjectAtIndex:index withObject:snapshot];

        [self.delegate childChanged:snapshot atIndex:index];
      }
      withCancelBlock:^(NSError *error) {
        [self.delegate canceledWithError:error];
      }];

  [self.query observeEventType:FIRDataEventTypeChildRemoved
      withBlock:^(FIRDataSnapshot *snapshot) {
        NSUInteger index = [self indexForKey:snapshot.key];

        [self.snapshots removeObjectAtIndex:index];

        [self.delegate childRemoved:snapshot atIndex:index];
      }
      withCancelBlock:^(NSError *error) {
        [self.delegate canceledWithError:error];
      }];

  [self.query observeEventType:FIRDataEventTypeChildMoved
      andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger fromIndex = [self indexForKey:snapshot.key];
        [self.snapshots removeObjectAtIndex:fromIndex];

        NSUInteger toIndex = [self indexForKey:previousChildKey] + 1;
        [self.snapshots insertObject:snapshot atIndex:toIndex];

        [self.delegate childMoved:snapshot fromIndex:fromIndex toIndex:toIndex];
      }
      withCancelBlock:^(NSError *error) {
        [self.delegate canceledWithError:error];
      }];
}

- (NSUInteger)indexForKey:(NSString *)key {
  if (!key) return -1;

  for (NSUInteger index = 0; index < [self.snapshots count]; index++) {
    if ([key isEqualToString:[(FIRDataSnapshot *)[self.snapshots objectAtIndex:index] key]]) {
      return index;
    }
  }

  NSString *errorReason =
      [NSString stringWithFormat:@"Key \"%@\" not found in FirebaseArray %@", key, self.snapshots];
  @throw [NSException exceptionWithName:@"FirebaseArrayKeyNotFoundException"
                                 reason:errorReason
                               userInfo:@{
                                 @"Key" : key,
                                 @"Array" : self.snapshots
                               }];
}

#pragma mark -
#pragma mark Public API methods

- (NSUInteger)count {
  return [self.snapshots count];
}

- (FIRDataSnapshot *)objectAtIndex:(NSUInteger)index {
  return (FIRDataSnapshot *)[self.snapshots objectAtIndex:index];
}

- (FIRDatabaseReference *)refForIndex:(NSUInteger)index {
  return [(FIRDataSnapshot *)[self.snapshots objectAtIndex:index] ref];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index{
	return [self objectAtIndex:index];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index{
  @throw [NSException exceptionWithName:@"FirebaseArraySetIndexWithSubscript"
                                 reason:@"Setting an object as FirebaseArray[i] is not supported."
                               userInfo:nil];
}

@end
