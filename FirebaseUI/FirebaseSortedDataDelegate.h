//
//  FirebaseSortedDataDelegate.h
//  ZoeLogDA
//
//  Created by Zoe Van Brunt on 12/1/15.
//  Copyright © 2015 Zoe Van Brunt. All rights reserved.
//

#ifndef FirebaseSortedDataDelegate_h
#define FirebaseSortedDataDelegate_h

@protocol FirebaseSortedDataDelegate <NSObject>

/**
 * Delegate method which is called whenever an object is added to the
 * FirebaseSortedData. This may correspond to an [FEventTypeChildAdded]
 * event. In the case of a FirebaseSortedData object with a predicate,
 * an [FEventTypeChildChanged] event may cause an object to conform to
 * the predicate when it previously didn't.
 * @param object The object added to the FirebaseSortedData
 * @param indexPath The indexPath the child was added at
 */
- (void)childAdded:(id)obj atIndexPath:(NSIndexPath *)indexPath;

/**
 * Delegate method which is called when an object is changed in the
 * FirebaseSortedData. This corresponds to an [FEventTypeChildChanged]
 * event. In the case of FirebaseSortedData with a predicate, this
 * method is only called if the [FEventTypeChildChanged] event does not
 * result in the object being removed or added due to the predicate's
 * evaluation.
 * @param object The object that changed in the FirebaseSortedData
 * @param indexPath The indexPath the child was changed at
 */
- (void)childChanged:(id)obj atIndexPath:(NSIndexPath *)indexPath;

/**
 * Delegate method which is called whenever an object is removed from the
 * FirebaseSortedData. This may correspond to an [FEventTypeChildRemoved]
 * event. In the case of a FirebaseSortedData object with a predicate,
 * an [FEventTypeChildChanged] event may cause an object to no longer
 * conform to the predicate when it previously did.
 * @param object The object removed from the FirebaseSortedData
 * @param indexPath The indexPath the child was removed at
 */
- (void)childRemoved:(id)obj atIndexPath:(NSIndexPath *)indexPath;

/**
 * Delegate method which is called whenever a new section is created by
 * FirebaseSortedData. This method is called even if sectionKeyPath is 
 * not set on FirebaseSortedData. This may correspond to an
 * [FEventTypeChildChanged] or [FEventTypeChildAdded] event.
 * @param section The index of the section to be added.
 */
- (void)sectionAddedAtSectionIndex:(NSUInteger)section;

/**
 * Delegate method which is called whenever a section is removed by
 * FirebaseSortedData. This method is called even if sectionKeyPath is
 * not set on FirebaseSortedData. This may correspond to an
 * [FEventTypeChildChanged] or [FEventTypeChildRemoved] event.
 * @param section The index of the section to be removed.
 */
- (void)sectionRemovedAtSectionIndex:(NSUInteger)section;

/**
 * Delegate method which is called to alert the delegate that multiple
 * complex changes are about to occur simultaneously. This would call
 * beginUpdates on a tableView, for example.
 */
- (void)beginUpdates;

/**
 * Delegate method which is called to alert the delegate that multiple
 * complex changes have occured simultaneously. This would call endUpdates 
 * on a tableView, for example.
 */
- (void)endUpdates;

/**
 * Delegate method which is called to induce the delegate to reload data
 * completely. This would call reloadData on a tableView, for example.
 * This method is called when a predicate or sortDescriptor is changed on
 * the FirebaseSortedData.
 */
- (void)reload;

@end


#endif /* FirebaseSortedDataDelegate_h */
