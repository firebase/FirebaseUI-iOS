//
//  FirebaseSortedData.h
//  FirebaseUI
//
//  Created by Zoe Van Brunt on 11/25/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FirebaseSetDelegate.h"
#import "FirebaseSortedDataDelegate.h"
#import "FirebaseSetObject.h"

@class FirebaseSet, FQuery, Firebase;

/**
 * @p FirebaseSortedData is a wrapper object for a @p FirebaseSet that provides
 * an optionally sorted and filtered representation that is suitable for
 * building a dataSource for a @p UITableView or @p UICollectionView.
 * @code
 FirebaseSortedData * data = [[FirebaseSortedData alloc] init];
 data.predicate = aPredicate;
 data.sectionKeyPath = \@"a.key.path";
 data.sectionsOrderedAscending = NO;
 data.sortDescriptors = @[aSortDescriptor, anotherSortDescriptor];
 data.firebaseSet = myFirebaseSet; // Set the firebaseSet property last
 */
@interface FirebaseSortedData : NSObject <FirebaseSetDelegate>

/**
 * The @p FirebaseSet which the @p FirebaseSortedData is built upon.
 */
@property (nonatomic, strong) FirebaseSet * firebaseSet;

/**
 * The delegate to which updates are surfaced.
 * @see FirebaseSortedDataDelegate
 */
@property (nonatomic, weak) id <FirebaseSortedDataDelegate> delegate;

/**
 * This propery returns a sorted representation of all the sorted and 
 * filtered objects at the moment it was called for.
 */
@property (nonatomic, readonly) NSArray <id <FirebaseSetObject>> * sortedObjects;

/**
 * The array of @p NSSortDescriptors by which the data is sorted. The 
 * zeroth being the most significant descriptor.
 * @warning Setting this property will cause a delegate call to reload if
 * the @p firebaseSet property is not @p nil.
 * @see FirebaseSortedDataDelegate
 */
@property (nonatomic, strong) NSArray <NSSortDescriptor *> * sortDescriptors;

/**
 * The NSPredicate by which the data is filtered.
 * @warning Setting this property will cause a delegate call to reload if
 * the @p firebaseSet property is not @p nil.
 * @see FirebaseSortedDataDelegate
 */
@property (nonatomic, strong) NSPredicate * predicate;

/**
 * The key path by which data is divided into sections. Use this as you
 * would for @p valueForKeyPath: in the @p \@"property.subproperty" format.
 * @warning Keep in mind what kind of objects you are using. If the
 * FirebaseSet uses a custom object class, use the appropriate keypath.
 * Otherwise, for an @p FDataSnapshot, you may have to format your keyPath
 * @p \@"value.yourKey" in order to access your values.
 * @warning Setting this property will cause a delegate call to reload if
 * the @p firebaseSet property is not @p nil.
 * @see FDataSnapshot, FirebaseSet
 */
@property (nonatomic, strong) NSString * sectionKeyPath;

/**
 * Use in conjunction with @p sectionKeyPath to determine whether sections
 * are ordered in ascending order by the @p compare: method.
 * @warning Setting this property will cause a delegate call to reload if
 * the @p firebaseSet property is not @p nil.
 */
@property (nonatomic) BOOL sectionsOrderedAscending;

/**
 * A sorted array of the values sections are determined by.
 * @return @p nil if @p sectionKeyPath is not set.
 */
@property (nonatomic, readonly) NSArray <id> * sectionValues;

/**
 * The total number of objects in the @p FirebaseSortedData object.
 */
@property (nonatomic) NSUInteger count;

/**
 * The total number of sections in the @p FirebaseSortedData object.
 */
@property (nonatomic) NSUInteger numberOfSections;

#pragma mark Initializer Methods

/**
 * Initializes @p FirebaseSortedData with a @p Firebase reference.
 * @param ref The @p Firebase reference with which to create the underlying
 * @p FirebaseSet.
 * @see FirebaseSet, Firebase
 */
- (instancetype)initWithRef:(Firebase *)ref;

/**
 * Initializes @p FirebaseSortedData with a @p FirebaseSet.
 * @param ref The underlying @p FirebaseSet.
 * @warning This will not call @p initiateObservers on the @p firebaseSet.
 * @see FirebaseSet
 */
- (instancetype)initWithFirebaseSet:(FirebaseSet *)firebaseSet;

#pragma mark API Methods

/**
 * Returns the number of objects in a section.
 * @param sectionIndex The section to retrieve the number of objects from.
 * @returns The number of objects in the section.
 */
- (NSUInteger)numberOfObjectsInSection:(NSUInteger)sectionIndex;

/**
 * Returns an array of the objects in a section.
 * @param sectionIndex The section to retrieve the objects from.
 * @returns An array of sorted objects in the section.
 */
- (NSArray *)sectionAtIndex:(NSUInteger)sectionIndex;

/**
 * Returns the object in the @p FirebaseSortedData at the @p indexPath.
 * @param indexPath The @p NSIndexPath from which to retrieve the object.
 * @returns The object at the @p indexPath.
 * @see NSIndexPath
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
