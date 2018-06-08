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

#import "FUIQueryObserver.h"

@interface FUIQueryObserver ()

@property (nonatomic, readonly) NSMutableSet<NSNumber *> *handles;
@property (nonatomic, readwrite) FIRDataSnapshot *contents;

@end

@implementation FUIQueryObserver

- (instancetype)init {
  self = [self initWithQuery:(id _Nonnull)nil]; // silence a clang warning
  NSException *e =
  [NSException exceptionWithName:@"FIRUnavailableMethodException"
                          reason:@"-init is unavailable. Please use the designated initializer instead."
                        userInfo:nil];
  @throw e;
}

- (instancetype)initWithQuery:(id<FUIDataObservable>)query {
  self = [super init];
  if (self != nil) {
    _query = query;
    _handles = [NSMutableSet setWithCapacity:4];
  }
  return self;
}

+ (FUIQueryObserver *)observerForQuery:(id<FUIDataObservable>)query
                            completion:(void (^)(FUIQueryObserver *obs,
                                                 FIRDataSnapshot *snap,
                                                 NSError *error))completion {
  FUIQueryObserver *obs = [[FUIQueryObserver alloc] initWithQuery:query];

  void (^observerBlock)(FIRDataSnapshot *, NSString *) = ^(FIRDataSnapshot *snap,
                                                           NSString *previous) {
    obs.contents = snap;
    completion(obs, snap, nil);
  };
  void (^cancelBlock)(NSError *) = ^(NSError *error) {
    completion(obs, nil, error);
  };

  [obs observeEventType:FIRDataEventTypeValue
    andPreviousSiblingKeyWithBlock:observerBlock withCancelBlock:cancelBlock];
  return obs;
}

- (void)observeEventType:(FIRDataEventType)eventType
andPreviousSiblingKeyWithBlock:(void (^)(FIRDataSnapshot *snapshot, NSString *__nullable prevKey))block
         withCancelBlock:(nullable void (^)(NSError* error))cancelBlock {
  FIRDatabaseHandle observerHandle = [self.query observeEventType:eventType
                                   andPreviousSiblingKeyWithBlock:block
                                                  withCancelBlock:cancelBlock];
  NSNumber *handle = @(observerHandle);
  if ([self.handles containsObject:handle]) {
    [self.query removeObserverWithHandle:handle.unsignedIntegerValue];
  }

  [self.handles addObject:handle];
}

- (void)dealloc {
  [self removeAllObservers];
}

- (void)removeAllObservers {
  for (NSNumber *handle in _handles) {
    [_query removeObserverWithHandle:handle.unsignedIntegerValue];
  }
}

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[self class]]) { return NO; }
  FUIQueryObserver *obs = object;
  return [self.query isEqual:obs.query];
}

@end
