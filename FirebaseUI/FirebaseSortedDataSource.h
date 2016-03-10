//
//  FirebaseSortedDataSource.h
//  FirebaseUI
//
//  Created by Zoe Van Brunt on 11/26/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FirebaseSet.h"
#import "FirebaseSortedData.h"

@interface FirebaseSortedDataSource : NSObject

@property (nonatomic, strong) FirebaseSet * firebaseSet;
@property (nonatomic, strong) FirebaseSortedData * data;

@property (nonatomic, strong) NSString * (^sectionTitleBlock)(id sectionValue);
@property (nonatomic, strong, setter = populateCellWithBlock:) void (^populateCellBlock)(id cell, NSObject * object);

@property (nonatomic, strong) NSString * nibName;
@property (nonatomic, strong) Class cellClass;
@property (nonatomic, strong) NSString * cellReuseIdentifier;
@property (nonatomic) NSString * prototypeCellReuseIdentifier;
@property (nonatomic) BOOL hasPrototypeCell;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)count;

- (NSString *)sectionTitleForSection:(NSUInteger)section;

- (void)populateCellWithBlock:(void (^)(id cell, NSObject * object))block;

@end
