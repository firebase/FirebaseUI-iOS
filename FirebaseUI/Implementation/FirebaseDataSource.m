//
//  FirebaseDataSource.m
//  FirebaseUI
//
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <Firebase/Firebase.h>

#import "FirebaseDataSource.h"

@implementation FirebaseDataSource

#pragma mark -
#pragma mark Initializer methods

- (instancetype)initWithArray:(FirebaseArray *)array;
{
    self = [super init];
    if (self) {
        self.array = array;
        self.array.delegate = self;
    }
    return self;
}

#pragma mark -
#pragma mark API methods

- (NSUInteger)count;
{
    return [self.array count];
}

- (id)objectAtIndex:(NSUInteger)index;
{
    return [self.array objectAtIndex:index];
}

- (Firebase *)refForIndex:(NSUInteger)index;
{
    return [self.array refForIndex:index];
}

@end
