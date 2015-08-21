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

/**
 * A protocol to allow instances of FirebaseArray to raise events through a delegate. Raises all
 * Firebase events except FEventTypeValue.
 */
@protocol FirebaseArrayDelegate<NSObject>

@optional

/**
 * Delegate method which is called whenever an object is added to a FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FEventTypeChildAdded](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The object added to the FirebaseArray
 * @param index The index the child was added at
 */
- (void)childAdded:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is chinged in a FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FEventTypeChildChanged](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The object that changed in the FirebaseArray
 * @param index The index the child was changed at
 */
- (void)childChanged:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is removed from a FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FEventTypeChildRemoved](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The object removed from the FirebaseArray
 * @param index The index the child was removed at
 */
- (void)childRemoved:(id)object atIndex:(NSUInteger)index;

/**
 * Delegate method which is called whenever an object is moved within a FirebaseArray. On a
 * FirebaseArray synchronized to a Firebase reference, this corresponds to an
 * [FEventTypeChildMoved](https://www.firebase.com/docs/ios/guide/retrieving-data.html#section-event-types)
 * event being raised.
 * @param object The object that has moved locations in the FirebaseArray
 * @param fromIndex The index the child is being moved from
 * @param toIndex The index the child is being moved to
 */
- (void)childMoved:(id)object fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
