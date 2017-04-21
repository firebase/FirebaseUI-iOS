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

#import "FUIAuthUtils.h"

NS_ASSUME_NONNULL_BEGIN

/** @var kActivityIndiactorPadding
    @brief The padding between the activity indiactor and its overlay.
 */
static const CGFloat kActivityIndiactorPadding = 20.0f;

/** @var kActivityIndiactorOverlayCornerRadius
    @brief The corner radius of the overlay of the activity indicator.
 */
static const CGFloat kActivityIndiactorOverlayCornerRadius = 20.0f;

/** @var kActivityIndiactorOverlayOpacity
    @brief The opacity of the overlay of the activity indicator.
 */
static const CGFloat kActivityIndiactorOverlayOpacity = 0.8f;

@implementation FUIAuthUtils

+ (NSBundle *)frameworkBundle {
  static NSBundle *frameworkBundle = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    frameworkBundle = [NSBundle bundleForClass:[self class]];
  });
  return frameworkBundle;
}

+ (UIImage *)imageNamed:(NSString *)name {
  NSString *path = [[[self class] frameworkBundle] pathForResource:name ofType:@"png"];
  return [UIImage imageWithContentsOfFile:path];
}

+ (UIActivityIndicatorView *)addActivityIndicator:(UIView *)view {
  UIActivityIndicatorView *activityIndicator =
      [[UIActivityIndicatorView alloc]
           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  activityIndicator.frame = CGRectInset(activityIndicator.frame,
                                        -kActivityIndiactorPadding,
                                        -kActivityIndiactorPadding);
  activityIndicator.backgroundColor =
  [UIColor colorWithWhite:0 alpha:kActivityIndiactorOverlayOpacity];
  activityIndicator.layer.cornerRadius = kActivityIndiactorOverlayCornerRadius;
  [view addSubview:activityIndicator];

    CGPoint activityIndicatorCenter = view.center;
  // Compensate for bounds adjustment if any.
  activityIndicatorCenter.y += view.bounds.origin.y;
  activityIndicator.center = activityIndicatorCenter;

  return activityIndicator;
}

NS_ASSUME_NONNULL_END

@end
