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

@property (nonatomic, readonly) IBInspectable NSString *placeholderChar;

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
  self.backgroundColor = UIColor.clearColor;
  self.tintColor = UIColor.clearColor;
  self.font = [UIFont fontWithName:@"Courier" size:40];
  self.textAlignment = NSTextAlignmentLeft;
  UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, self.bounds.size.height)];
  self.leftView = paddingView;
  self.leftViewMode = UITextFieldViewModeAlways;
  self.textContentType = UITextContentTypeOneTimeCode;

  // Default values
  if (!self.codeLength) {
    _codeLength = 6;
  } else {
    _codeLength = MIN(self.codeLength, 12);
  }

  if (!self.placeholderChar || !self.placeholderChar.length) {
    _placeholderChar = @"-";
  }

  self.delegate = self;
  [self updateText];
}

- (UIKeyboardType) keyboardType {
  if (@available(iOS 10, *)) {
    return UIKeyboardTypeASCIICapableNumberPad;
  } else {
    return UIKeyboardTypeNumberPad;
  }
}

- (BOOL)hasText {
  return self.codeEntry.length > 0;
}

- (void)insertText:(NSString *)theText {
  if (self.codeEntry.length >= self.codeLength){
    // UX: if code was submitted and there is an error message,
    //     typing a new number should clear the field and start over
    [self updateText];
    return;
  }

  [self.codeEntry appendString:theText];
  [self updateText];
  [self notifyEntryCompletion];
}

- (void)deleteBackward {
  if (!self.codeEntry.length) {
    return;
  }

  NSRange theRange = NSMakeRange(self.codeEntry.length - 1, 1);
  [self.codeEntry deleteCharactersInRange:theRange];
  [self updateText];
  [self notifyEntryCompletion];
}

- (void)clearCodeInput {
  [self.codeEntry setString:@""];
  [self updateText];
  [self notifyEntryCompletion];
}

- (void)notifyEntryCompletion {
  if (self.codeEntry.length >= self.codeLength) {
    [self.codeDelegate entryIsCompletedWithCode:[self.codeEntry copy]];
  } else {
    [self.codeDelegate entryIsIncomplete];
  }
}

- (void)updateText {
    NSString *code = [self.codeEntry copy];
    if (self.secureTextEntry) {
      code = [[NSString string] stringByPaddingToLength:code.length
                                             withString:@"\u2022" startingAtIndex:0];
    }

    NSInteger add = self.codeLength - code.length;
    if (add > 0) {
      NSString *pad = [[NSString string] stringByPaddingToLength:add
                                                      withString:self.placeholderChar
                                                 startingAtIndex:0];
      code = [code stringByAppendingString:pad];
    }

    NSMutableAttributedString *attributedString =
        [[NSMutableAttributedString alloc] initWithString:code];
    [attributedString addAttribute:NSKernAttributeName value:@20
                             range:NSMakeRange(0, attributedString.length - 1)];
    self.attributedText = attributedString;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length == 0) {
        [self deleteBackward];
    } else {
        [self insertText:string];
    }
    return false;
}

@end

NS_ASSUME_NONNULL_END
