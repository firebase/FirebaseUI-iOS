//
//  FirebaseSetDelegate.h
//  FirebaseUI
//
//  Created by Zoe Van Brunt on 11/25/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#ifndef FirebaseSetDelegate_h
#define FirebaseSetDelegate_h

#import "FirebaseSetObject.h"

@class FirebaseSet;

@protocol FirebaseSetDelegate<NSObject>

@optional

/**
 * Delegate method which is called whenever an object is added to the set.
 * This method corresponds to an @p [FEventTypeChildAdded] event.
 * @param firebaseSet The @p firebaseSet which is the sender.
 * @param obj The object being added to the set.
 */
- (void)firebaseSet:(FirebaseSet *)firebaseSet added:(NSObject <FirebaseSetObject> *)obj;

/**
 * Delegate method which is called whenever an object is removed from the
 * set. This method corresponds to an @p [FEventTypeChildRemoved] event.
 * @param firebaseSet The @p firebaseSet which is the sender.
 * @param obj The object being removed from the set.
 */
- (void)firebaseSet:(FirebaseSet *)firebaseSet removed:(NSObject <FirebaseSetObject> *)obj;

/**
 * Delegate method which is called whenever an object is changed in the
 * set. This method corresponds to an @p [FEventTypeChildChanged] event.
 * @param firebaseSet The @p firebaseSet which is the sender.
 * @param obj The object that has been changed within the set.
 */
- (void)firebaseSet:(FirebaseSet *)firebaseSet changed:(NSObject <FirebaseSetObject> *)obj;

/**
 * Delegate method which is called once after all the initial add events
 * are complete. This method corresponds to the first @p [FEventTypeValue]
 * event guaranteed to happen after all @p [FEventTypeChildAdded] events have
 * occured.
 * @param firebaseSet The @p firebaseSet which is the sender.
 * @warning This method will fire in addition to 
 * @p firebaseSetCompletedUpdates
 */
- (void)firebaseSetCompletedInitialization:(FirebaseSet *)firebaseSet;

/**
 * Delegate method which is called after all incoming updates have fired.
 * This method corresponds to an @p [FEventTypeValue] event.
 * @param firebaseSet The firebaseSet which is the sender.
 * @warning The first time this method will fire will be in addition to the
 * single @p firebaseSetCompletedInitialization call.
 */
- (void)firebaseSetCompletedUpdates:(FirebaseSet *)firebaseSet;

@end

#endif /* FirebaseSetDelegate_h */
