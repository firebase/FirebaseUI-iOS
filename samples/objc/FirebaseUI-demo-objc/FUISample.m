//
//  FUISample.m
//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "FUISample.h"

@implementation FUISample

- (id)initWithTitle:(NSString *)title
  sampleDescription:(NSString *)description
         controller:(FIRControllerBlock)block {
  if (self = [self init]) {
    _title = [title copy];
    _sampleDescription = [description copy];
    _controllerBlock = [block copy];
  }

  return self;
}

+ (instancetype)sampleWithTitle:(NSString *)title
              sampleDescription:(NSString *)description
                     controller:(FIRControllerBlock)block {
  FUISample *sample = [(FUISample *)[self alloc] initWithTitle:title
                                             sampleDescription:description
                                                    controller:block];

  return sample;
}

@end
