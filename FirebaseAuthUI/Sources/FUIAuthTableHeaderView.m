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

#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthTableHeaderView.h"

/** @var kLabelHorizontalMargin
    @brief The horizontal margin around any @c UILabel.
 */
static const CGFloat kLabelHorizontalMargin = 8.0f;

/** @var kLabelVerticalMargin
    @brief The veritcal margin around any @c UILabel.
 */
static const CGFloat kLabelVerticalMargin = 16.0f;

@implementation FUIAuthTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [self addSubview:_titleLabel];

    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [UIFont systemFontOfSize:14.0f];
    _detailLabel.numberOfLines = 0;
    [self addSubview:_detailLabel];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  [_titleLabel sizeToFit];

  CGRect contentRect = CGRectInset(self.bounds, kLabelHorizontalMargin, kLabelVerticalMargin);
  CGRect titleLabelFrame, detailLabelFrame, space;
  CGRectDivide(contentRect, &titleLabelFrame, &contentRect,
               CGRectGetHeight(_titleLabel.frame), CGRectMinYEdge);
  CGRectDivide(contentRect, &space, &detailLabelFrame, kLabelVerticalMargin, CGRectMinYEdge);

  _titleLabel.frame = titleLabelFrame;
  _detailLabel.frame = detailLabelFrame;
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGFloat labelWidth = size.width - kLabelHorizontalMargin * 2;
  CGFloat titleLabelHeight = [[self class] sizeForLabel:_titleLabel maxWidth:labelWidth].height;
  CGFloat detailLabelHeight = [[self class] sizeForLabel:_detailLabel maxWidth:labelWidth].height;
  CGFloat height = titleLabelHeight + detailLabelHeight + kLabelVerticalMargin * 3;
  return CGSizeMake(size.width, height);
}

#pragma mark - Utility

/** @fn sizeForLabel:maxWidth:
    @brief Calculate the with of the @c UILabel with the given maximum width.
    @return The calculated size.
 */
+ (CGSize)sizeForLabel:(UILabel *)label maxWidth:(CGFloat)maxWidth {
  CGRect rect = [label.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{ NSFontAttributeName : label.font }
                                         context:nil];
  return CGRectIntegral(rect).size;
}

@end
