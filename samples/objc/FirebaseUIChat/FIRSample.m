//
//  FIRSampleContainer.m
//  FirebaseUIChat
//
//  Created by Yury Ramanchuk on 9/8/16.
//  Copyright © 2016 Firebase, Inc. All rights reserved.
//

#import "FIRSample.h"

@implementation FIRSample

- (id)initWithTitle:(NSString *)title
  sampleDescription:(NSString *)description
         controller:(FIRControllerBlock)block {
    if (self = [self init]) {
        _title = title;
        _sampleDescription = description;
        _controllerBlock = block;
    }

    return self;
}

+ (instancetype)sampleWithTitle:(NSString *)title
              sampleDescription:(NSString *)description
                     controller:(FIRControllerBlock)block {
    FIRSample *sample = [(FIRSample *)[self alloc] initWithTitle:title
                                               sampleDescription:description
                                                      controller:block];

    return sample;
}


@end