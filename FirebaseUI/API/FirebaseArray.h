//
//  FirebaseArray.h
//  FirebaseToolkit
//
//  Created by Mike Mcdonald on 7/8/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Firebase;

@protocol FirebaseArrayDelegate;

@interface FirebaseArray : NSObject

@property (weak, nonatomic) id<FirebaseArrayDelegate> delegate;

@property (strong, nonatomic) Firebase *ref;
@property (strong, nonatomic) NSMutableArray *snapshots;

#pragma mark -
#pragma mark Initializer methods

- (instancetype)initWithRef:(Firebase *)ref;
- (instancetype)initWithQuery:(Firebase *)ref;

#pragma mark -
#pragma mark Public API methods

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (Firebase *)refForIndex:(NSUInteger)index;

#pragma mark -
#pragma mark Private API methods

- (NSUInteger)indexForKey:(NSString *)key;

@end

@protocol FirebaseArrayDelegate <NSObject>

@optional
- (void) childAdded:(id)obj atIndex:(NSUInteger)index;
- (void) childChanged:(id)obj atIndex:(NSUInteger)index;
- (void) childMoved:(id)obj fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void) childRemoved:(id)obj atIndex:(NSUInteger)index;

@end
