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

#import <Foundation/Foundation.h>
#import <FirebaseUI/XCodeMacros.h>

#import "FirebaseArrayDelegate.h"

@class FQuery;
@class Firebase;
@class FDataSnapshot;

/**
 * FirebaseArray provides an array structure that is synchronized with a Firebase reference or
 * query. It is useful for building custom data structures or sources, and provides the base for
 * FirebaseDataSource.
 */
@interface FirebaseArray : NSObject

/**
 * The delegate object that array changes are surfaced to, which conforms to the
 * [FirebaseArrayDelegate Protocol](FirebaseArrayDelegate).
 */
@property(weak, nonatomic) id<FirebaseArrayDelegate> delegate;

/**
 * The query on a Firebase reference that provides data to populate the instance of FirebaseArray.
 */
@property(strong, nonatomic) FQuery *query;

/**
 * The delegate object that array changes are surfaced to.
 */
@property(strong, nonatomic) NSMutableArray __GENERIC(FDataSnapshot *) * snapshots;
@property(strong, nonatomic) NSMutableOrderedSet __GENERIC(id) * sectionValues;

#pragma mark -
#pragma mark Initializer methods

/**
 * Intitalizes FirebaseArray with a standard Firebase reference.
 * @param ref The Firebase reference which provides data to FirebaseArray
 * @return The instance of FirebaseArray
 */
- (instancetype)initWithRef:(Firebase *)ref;

/**
 * Intitalizes FirebaseArray with a Firebase query (FQuery).
 * @param query A query on a Firebase reference which provides filtered data to FirebaseArray
 * @return The instance of FirebaseArray
 */
- (instancetype)initWithQuery:(FQuery *)query;

/**
 * Initializes FirebaseArray with a Firebase query (FQuery), an array of NSSortDescriptors, and an
 * NSPredicate.
 * Use this if you would like the array to be sorted after being received from the server, or if
 * you would like more complex sorting or filtering behavior than an FQuery can provide.
 * @param query A query on a Firebase reference which provides filtered data to FirebaseArray
 * @param predicate The predicate by which the snapshots are filtered. If predicate is nil, the array
 * reflects all results from the Firebase Query or Reference.
 * @return The instance of FirebaseArray
 */
- (instancetype)initWithQuery:(FQuery *)query
                    predicate:(NSPredicate *)predicate;


/**
 * Initializes FirebaseArray with a Firebase query (FQuery), an array of NSSortDescriptors, and an
 * NSPredicate.
 * Use this if you would like the array to be sorted after being received from the server, or if
 * you would like more complex sorting or filtering behavior than an FQuery can provide.
 * @param query A query on a Firebase reference which provides filtered data to FirebaseArray
 * @param sortDescriptors The sort descriptors by which the array should be ordered. If the array is
 * empty or nil, the array is ordered by [snapshot1.key compare:snapshot2.key]
 * @param predicate The predicate by which the snapshots are filtered. If predicate is nil, the array
 * reflects all results from the Firebase Query or Reference.
 * @return The instance of FirebaseArray
 */
- (instancetype)initWithQuery:(FQuery *)query
              sortDescriptors:(NSArray *)sortDescriptors
                    predicate:(NSPredicate *)predicate;

/**
 * Initializes FirebaseArray with a standard Firebase reference and an array of NSSortDescriptors.
 * Use this if you would like the array to be sorted after being received from the server, or if
 * you would like more complex sorting behavior.
 * @param ref The Firebase reference which provides data to FirebaseArray
 * @param sortDescriptors The sort descriptors by which the array should be ordered. If the array is
 * empty or nil, the array is ordered by [snapshot1.key compare:snapshot2.key]
 * @return The instance of FirebaseArray
 */
-(instancetype)initWithRef:(Firebase *)ref sortDescriptors:(NSArray *)sortDescriptors;

/**
 * Initializes FirebaseArray with a Firebase query (FQuery) and an array of NSSortDescriptors.
 * Use this if you would like the array to be sorted after being received from the server, or if
 * you would like more complex sorting behavior than an FQuery can provide.
 * It is recommended that you use FQuery to filter, rather than sort, for use with this initializer.
 * E.G. query only objects that have false for their hidden flag, then sort using Sort Descriptors.
 * @param query A query on a Firebase reference which provides filtered data to FirebaseArray
 * @param sortDescriptors The sort descriptors by which the array should be ordered. If the array is
 * empty or nil, the array is ordered by [snapshot1.key compare:snapshot2.key]
 * @return The instance of FirebaseArray
 */
-(instancetype)initWithQuery:(FQuery *)query sortDescriptors:(NSArray *)sortDescriptors;

#pragma mark -
#pragma mark Public API methods

/**
 * Returns the count of objects in the FirebaseArray.
 * @return The count of objects in the FirebaseArray
 */
- (NSUInteger)count;

/**
 * Returns an object at a specific index in the FirebaseArray.
 * @param index The index of the item to retrieve
 * @return The object at the given index
 */
- (FDataSnapshot *)objectAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns a Firebase reference for an object at a specific index in the FirebaseArray.
 * @param index The index of the item to retrieve a reference for
 * @return A Firebase reference for the object at the given index
 */
- (Firebase *)refForIndexPath:(NSIndexPath *)indexPath;

/**
 * The sort descriptors by which the array should be ordered. If the array is empty or nil, the
 * array is ordered by [snapshot1.key compare:snapshot2.key]
 */
@property (strong, nonatomic) NSArray * sortDescriptors;

- (NSIndexPath *)indexPathOfObject:(FDataSnapshot *)snapshot;

#pragma mark -
#pragma mark Private API methods

- (NSIndexPath *)indexPathForKey:(NSString *)key;

/**
 * The predicate by which the snapshots are filtered. If predicate is nil, the array reflects all
 * results from the Firebase Query or Reference.
 */
@property (strong, nonatomic) NSPredicate * predicate;

@property (strong, nonatomic) NSString * sectionKeyPath;
@property (nonatomic) BOOL sectionsOrderedAscending;

- (NSArray *)sectionAtIndex:(NSUInteger)sectionIndex;

@end
