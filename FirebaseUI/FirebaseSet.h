//
//  FirebaseSet.h
//  FirebaseUI
//
//  Created by Zoe Van Brunt on 11/25/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

// clang-format on

#import <Foundation/Foundation.h>

#import "FirebaseSetDelegate.h"
#import "FirebaseSetObject.h"
#import "FirebaseSortedData.h"

@class Firebase, FQuery, FDataSnapshot;

/**
 * FirebaseSet provides a set wrapper that is synchronized with a Firebase
 * reference of query. It is useful for building custom data structures or 
 * sources. A FirebaseSet can be used as a property to keep remote data in 
 * memory, and then to pass into another data source for more performant 
 * data accessibility.
 */
@interface FirebaseSet : NSObject

/**
 * The Firebase reference that provides data to populate the instance of 
 * FirebaseSet.
 */
@property (nonatomic, strong) Firebase * ref;

/**
 * An immutable representation of the objects in the FirebaseSet.
 */
@property (nonatomic, strong, readonly) NSSet<id> * objects;

/**
 * @returns A new sorted data object for this FirebaseSet
 */
@property (nonatomic, readonly) FirebaseSortedData * sortedData;

/**
 * Returns true if the FirebaseSet has finished receiving all the initial
 * updates. Updated when the first FEventTypeValue event fires.
 */
@property (nonatomic, readonly) BOOL initialValuesSet;

/**
 * How many objects are currently in the FirebaseSet.
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 * Use this block to convert a snapshot into your custom class of choice.
 * You must set this property before calling @p initiateObservers, if at all.
 * If you set this property the @p FirebaseSet will return objects of your
 * custom class instead of @p FDataSnapshots.
 * @param snap The @p FDataSnapshot that you use to create your custom object.
 * @warning Your custom class must conform to the @p FirebaseSetObject
 * protocol.
 * @warning Set this block before calling @p initiateObservers.
 * @see FirebaseSetObject, FDataSnapshot
 */
@property (nonatomic, strong) id <FirebaseSetObject> (^classConversionBlock)(FDataSnapshot * snap);

/**
 * Use this block to customize handling of changes. If this block is not 
 * set, the default behavior is to simply replace the original with the new
 * one.
 * @param snap The @p FDataSnapshot that represents the changed state of the
 * object
 * @param matchingObject the object that is being changed. If 
 * @p classConversionBlock is not set, this is an @p FDataSnapshot.
 * @return The changed object, usually @p matchingObject after applying changes.
 * @see FirebaseSetObject, FDataSnapshot
 */
@property (nonatomic, strong) id <FirebaseSetObject> (^changeHandlerBlock)(FDataSnapshot * snap, id <FirebaseSetObject> matchingObject);

#pragma mark Public API Methods

/**
 * Add a delegate object receiver.
 * @param delegate a delegate object that changes are surfaced to, 
 * which conforms to the @p FirebaseSetDelegate protocol.
 * @see FirebaseSetDelegate
 */
- (void)addDelegate:(id <FirebaseSetDelegate>)delegate;

/**
 * Remove a delegate object so that it no longer receives delegate calls.
 * @param delegate the delegate object to remove.
 * @see FirebaseSetDelegate
 */
- (void)removeDelegate:(id <FirebaseSetDelegate>)delegate;

/**
 * Returns an object matching the supplied key.
 * @param key The key to match, specified in the @p FirebaseSetObject
 * protocol.
 * @see FirebaseSetObject
 */
- (id <FirebaseSetObject>)objectMatchingKey:(NSString *)key;

#pragma mark Initializer Methods

/**
 * Initializes @p FirebaseSet with a standard @p Firebase reference.
 * @param ref The @p Firebase reference which provides data to @p FirebaseSet
 * @return The instance of @p FirebaseSet
 * @see Firebase
 */
- (instancetype)initWithRef:(Firebase *)ref;

/**
 * Begins all observers for the @p FirebaseSet. You must call this method in
 * order for the @p FirebaseSet to begin any syncing.
 * @warning If you wish to set @p classConversion and @p changeHander blocks, you
 * must do so before calling this method.
 */
- (void)initiateObservers;

@end
