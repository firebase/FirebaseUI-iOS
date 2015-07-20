//
//  FirebaseDataSource.h
//  Firebase Toolkit
//
//  Created by Mike Mcdonald on 6/24/15.
//  Copyright (c) 2015 Firebase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FirebaseArray.h"

@class Firebase;

@protocol FirebaseDataSource;

@interface FirebaseDataSource : NSObject <FirebaseArrayDelegate>

@property (strong, nonatomic) FirebaseArray *array;
@property (strong, nonatomic) Class modelClass;
@property (strong, nonatomic) NSString *reuseIdentifier;

- (instancetype)initWithArray:(FirebaseArray *)array;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (Firebase *)refForIndex:(NSUInteger)index;

@end

