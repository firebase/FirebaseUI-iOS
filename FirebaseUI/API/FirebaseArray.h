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
- (id)objectAtIndex:(NSUInteger)index;

/**
 * Returns a Firebase reference for an object at a specific index in the FirebaseArray.
 * @param index The index of the item to retrieve a reference for
 * @return A Firebase reference for the object at the given index
 */
- (Firebase *)refForIndex:(NSUInteger)index;

#pragma mark -
#pragma mark Private API methods

/**
 * Returns an index for a given object's key (that matches the object's key in the corresponding
 * Firebase reference).
 * @param key The key of the desired object
 * @return The index of the object for which the key matches or -1 if the key is null
 * @exception FirebaseArrayKeyNotFoundException Thrown when the desired key is not in the
 * FirebaseArray, likely indicating that the FirebaseArray is no longer being properly synchronized
 * with the Firebase database.
 */
- (NSUInteger)indexForKey:(NSString *)key;

@end
