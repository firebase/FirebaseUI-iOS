//
//  FirebaseSortedObject.h
//  FirebaseUI
//
//  Created by Zoe Van Brunt on 11/26/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#ifndef FirebaseSetObject_h
#define FirebaseSetObject_h

@protocol FirebaseSetObject <NSObject>

/**
 * A unique identifier within the scope of the @p FirebaseSet's ref. The
 * recommended implementation would be to copy the @p FDataSnapshot's @p key 
 * property to your custom class.
 * @see FDataSnapshot
 */
- (NSString *)key;

@end


#endif /* FirebaseSetObject_h */
