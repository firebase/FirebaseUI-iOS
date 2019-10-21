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

@property (nonatomic, retain, readonly) UIView *inputField;

@property (weak, nonatomic) IBOutlet UILabel *digits;

@property (nonatomic, readonly) IBInspectable NSString *placeholder;

@end

@implementation FUICodeField

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]){
    [self setUpFromNib];
  }
  return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]){
    [self setUpFromNib];
  }
  return self;
}

- (void)setUpFromNib {
  NSBundle *bundle = [FUIAuthUtils bundleNamed:FUIPhoneAuthBundleName];
  UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle];

  _inputField = [nib instantiateWithOwner:self options:nil][0];
  self.inputField.frame = [self bounds];
  self.inputField.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.inputField.userInteractionEnabled = YES;

  // Initialization code
  _codeEntry = [NSMutableString string];

  // Default values
  if (!self.codeLength) {
    _codeLength = 6;
  } else {
    _codeLength = MIN(self.codeLength, 12);
  }

  if (!self.placeholder || !self.placeholder.length) {
    _placeholder = @"-";
  }

  [self addSubview:self.inputField];
}

- (UIKeyboardType) keyboardType {
  if (@available(iOS 10, *)) {
    return UIKeyboardTypeASCIICapableNumberPad;
  } else {
    return UIKeyboardTypeNumberPad;
  }
}

- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (void) touchesBegan: (NSSet *) touches withEvent: (nullable UIEvent *) event {
  [self becomeFirstResponder];
}

- (void)drawRect:(CGRect)rect {
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

  self.digits.text = @"";
  [self.digits setAttributedText:attributedString];
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
    [self.delegate entryIsCompletedWithCode:[self.codeEntry copy]];
  } else {
    [self.delegate entryIsIncomplete];
  }
}

- (CGSize)inputFieldIntrinsicContentSize {
  CGSize textFieldSize = [self.inputField intrinsicContentSize];
  if (textFieldSize.height < FUICodeFieldMinInputFieldHeight) {
    textFieldSize.height = FUICodeFieldMinInputFieldHeight;
  }

  return textFieldSize;
}

- (CGSize)intrinsicContentSize {
  CGSize textFieldSize = [self inputFieldIntrinsicContentSize];
  return textFieldSize;
}

- (UITextContentType _Null_unspecified)textContentType {
  if (@available(iOS 12.0, *)) {
    return UITextContentTypeOneTimeCode;
  }
  return nil;
}

@end

NS_ASSUME_NONNULL_END
