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

#import "FIRAuthUISignInButton.h"

#import "FIRAuthProviderUI.h"
#import "FIRAuthUIUtils.h"

/** @var kCornerRadius
    @brief Corner radius of the button.
 */
static const int kCornerRadius = 2.0f;

/** @var kDropShadowAlpha
    @brief Opacity of the drop shadow of the button.
 */
static const CGFloat kDropShadowAlpha = 0.24f;

/** @var kDropShadowRadius
    @brief Radius of the drop shadow of the button.
 */
static const CGFloat kDropShadowRadius = 2.0f;

/** @var kDropShadowYOffset
    @brief Vertical offset of the drop shadow of the button.
 */
static const CGFloat kDropShadowYOffset = 2.0f;

/** @var kFontSize
    @brief Button text font size.
 */
static const CGFloat kFontSize = 12.0f;

@implementation FIRAuthUISignInButton

- (instancetype)initWithFrame:(CGRect)frame
                        image:(UIImage *)image
                         text:(NSString *)text
              backgroundColor:(UIColor *)backgroundColor
                    textColor:(UIColor *)textColor {
  self = [super initWithFrame:frame];
  if (!self) {
    return nil;
  }

  self.backgroundColor = backgroundColor;
  [self setTitle:text forState:UIControlStateNormal];
  [self setTitleColor:textColor forState:UIControlStateNormal];
  self.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
  [self setImage:image forState:UIControlStateNormal];

  self.layer.cornerRadius = kCornerRadius;

  // Add a drop shadow.
  self.layer.masksToBounds = NO;
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOpacity = kDropShadowAlpha;
  self.layer.shadowRadius = kDropShadowRadius;
  self.layer.shadowOffset = CGSizeMake(0, kDropShadowYOffset);

  self.adjustsImageWhenHighlighted = NO;

  return self;
}

- (instancetype)initWithFrame:(CGRect)frame providerUI:(id<FIRAuthProviderUI>)providerUI {
  _providerUI = providerUI;
  return [self initWithFrame:frame
                       image:providerUI.icon
                        text:providerUI.signInLabel
             backgroundColor:providerUI.buttonBackgroundColor
                   textColor:providerUI.buttonTextColor];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGRect imageRect = self.imageView.frame;
  imageRect.origin.x = 8.0f;
  self.imageView.frame = imageRect;

  CGRect titleRect = self.titleLabel.frame;
  titleRect.origin.x = 50.0f;
  self.titleLabel.frame = titleRect;
}

@end
