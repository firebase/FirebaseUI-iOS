//
//  FRestDataSnapshot.m
//  FirebaseUI
//
//  Created by Chris Ellsworth on 12/5/15.
//  Copyright © 2015 Firebase, Inc. All rights reserved.
//

#import "FRestDataSnapshot.h"

@interface FRestDataSnapshot ()
@property(nonatomic, strong) Firebase *refInternal;
@property(nonatomic, strong) id valueInternal;
@end

@implementation FRestDataSnapshot

- (instancetype)initWithRef:(Firebase *)ref value:(id)value {
  if (self = [super init]) {
    self.refInternal = ref;
    self.valueInternal = value;
  }
  return self;
}

- (Firebase *)ref {
  return self.refInternal;
}

- (id)value {
  return self.valueInternal;
}

@end