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

#import "FirebaseArray.h"

@class Firebase;

/**
 * A FirebaseDataSource is a generic superclass for all Firebase datasources,
 * like
 * FirebaseTableViewDataSource and FirebaseCollectionViewDataSource. It provides
 * properties that all
 * subclasses need as well as several methods that pass through to the instance
 * of FirebaseArray.
 */
@interface FirebaseDataSource : NSObject<FirebaseArrayDelegate>

/**
 * The FirebaseArray which backs the instance of the datasource.
 */
@property(strong, nonatomic) FirebaseArray *array;

- (instancetype)initWithArray:(FirebaseArray *)array;

/**
 * Pass through of [FirebaseArray count].
 */
- (NSUInteger)count;

/**
 * Pass through of [FirebaseArray objectAtIndex:].
 */
- (id)objectAtIndex:(NSUInteger)index;

/**
 * Pass through of [FirebaseArray refForIndex:].
 */
- (Firebase *)refForIndex:(NSUInteger)index;

@end
