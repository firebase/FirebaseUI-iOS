//
//  FirebaseSortedDataSource.m
//  FirebaseUI
//
//  Created by Zoe Van Brunt on 11/26/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import "FirebaseSortedDataSource.h"

#import "FirebaseSortedData.h"
#import "FirebaseSet.h"

@implementation FirebaseSortedDataSource

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    FirebaseSortedData * data = [[FirebaseSortedData alloc] init];
    [self setData:data];
    
    return self;
}

- (void)setData:(FirebaseSortedData *)data;
{
    _data = data;
    data.delegate = (id <FirebaseSortedDataDelegate>)self;
}

- (FirebaseSet *)firebaseSet;
{
    return self.data.firebaseSet;
}

- (void)setFirebaseSet:(FirebaseSet *)set;
{
    self.data.firebaseSet = set;
}

- (NSString *)sectionTitleForSection:(NSUInteger)section;
{
    if (!self.data.sectionKeyPath || !self.data.sectionValues.count) {
        return nil;
    }
    id sectionValue = [self.data.sectionValues objectAtIndex:section];
    
    NSString * title;
    
    if (self.sectionTitleBlock) {
        title = self.sectionTitleBlock(sectionValue);
    } else {
        title = [NSString stringWithFormat:@"%@", sectionValue];
    }
    return title;
}

#pragma mark Public API Accessors

- (NSString *)prototypeCellReuseIdentifier;
{
    if (self.hasPrototypeCell) {
        return self.cellReuseIdentifier;
    }
    return nil;
}

- (void)setPrototypeCellReuseIdentifier:(NSString *)prototypeCellReuseIdentifier;
{
    self.hasPrototypeCell = YES;
    self.cellReuseIdentifier = prototypeCellReuseIdentifier;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
{
    return [self.data objectAtIndexPath:indexPath];
}

- (NSUInteger)count;
{
    return self.data.count;
}

@end
