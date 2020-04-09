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

#import "FUICodeField.h"

#import "FUIAuthUtils.h"
#import "FUIPhoneAuthStrings.h"

NS_ASSUME_NONNULL_BEGIN

const CGFloat FUICodeFieldMinInputFieldHeight = 60.0f;

@interface FUICodeField ()

@property (nonatomic, readonly) IBInspectable NSString *codePlaceholder;

@end

@implementation FUICodeField

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]){
      [self commonInit];
  }
  return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]){
      [self commonInit];
  }
  return self;
}

- (void)commonInit {
    // Initialization code
    _codeEntry = [NSMutableString string];

    // Default values
    if (!self.codeLength) {
      _codeLength = 6;
    } else {
      _codeLength = MIN(self.codeLength, 12);
    }

    if (!self.codePlaceholder || !self.codePlaceholder.length) {
      _codePlaceholder = @"-";
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
  NSString *code = [self.codeEntry copy];
  if (self.secureTextEntry) {
    code = [[NSString string] stringByPaddingToLength:code.length
                                           withString:@"\u2022" startingAtIndex:0];
  }

  NSInteger add = self.codeLength - code.length;
  if (add > 0) {
    NSString *pad = [[NSString string] stringByPaddingToLength:add
                                                    withString:self.placeholder
                                               startingAtIndex:0];
    code = [code stringByAppendingString:pad];
  }

  NSMutableAttributedString *attributedString =
      [[NSMutableAttributedString alloc] initWithString:code];
  [attributedString addAttribute:NSKernAttributeName value:@20
                           range:NSMakeRange(0, attributedString.length-1)];

  [self setAttributedText:attributedString];
}

- (BOOL)hasText {
  return self.codeEntry.length > 0;
}

- (void)insertText:(NSString *)theText {
  if (self.codeEntry.length >= self.codeLength){
    // UX: if code was submitted and there is an error message,
    //     typing a new number should clear the field and start over
    return;
  }

  [self.codeEntry appendString:theText];
  [self setNeedsDisplay];
  [self notifyEntryCompletion];
}

- (void)deleteBackward {
  if (!self.codeEntry.length){
    return;
  }

  NSRange theRange = NSMakeRange(self.codeEntry.length-1, 1);
  [self.codeEntry deleteCharactersInRange:theRange];
  [self setNeedsDisplay];
  [self notifyEntryCompletion];
}

- (void)clearCodeInput {
  [self.codeEntry setString:@""];

  [self setNeedsDisplay];
  [self notifyEntryCompletion];
}

- (void)notifyEntryCompletion {
  if (self.codeEntry.length >= self.codeLength) {
    [self.codeFieldDelegate entryIsCompletedWithCode:[self.codeEntry copy]];
  } else {
    [self.codeFieldDelegate entryIsIncomplete];
  }
}

- (CGSize)intrinsicContentSize {
  CGSize size = [super intrinsicContentSize];
    if (size.height < FUICodeFieldMinInputFieldHeight) {
        size.height = FUICodeFieldMinInputFieldHeight;
    }
  return size;
}

@end

NS_ASSUME_NONNULL_END
