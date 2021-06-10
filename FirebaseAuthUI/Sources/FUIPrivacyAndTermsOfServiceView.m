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

#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIPrivacyAndTermsOfServiceView.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuth.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthStrings.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FUIPrivacyAndTermsOfServiceView

#pragma mark - Public

- (void)useFullMessage {
  NSAttributedString *fullMessage = [self fullPrivacyPolicyAndTOSMessage];
  self.attributedText = fullMessage;
  self.textAlignment = NSTextAlignmentLeft;
}

- (void)useFooterMessage {
  NSAttributedString *footerMessage = [self footerPrivacyPolicyAndTOSMessage];
  self.attributedText = footerMessage;
  self.textAlignment = NSTextAlignmentRight;
}

#pragma mark - Protected

- (nullable NSAttributedString *)privacyPolicyAndTOSMessageFromFormat:(NSString *)format {
  FUIAuth *authUI = self.authUI ?: [FUIAuth defaultAuthUI];
  NSURL *TOSURL = authUI.TOSURL;
  NSURL *privacyPolicyURL = authUI.privacyPolicyURL;
  NSUInteger TOSURLStringLength = TOSURL.absoluteString.length;
  NSUInteger privacyPolicyURLStringLength = privacyPolicyURL.absoluteString.length;

  if (!TOSURLStringLength && !privacyPolicyURLStringLength) {
    return nil;
  }
  if (!TOSURLStringLength || !privacyPolicyURLStringLength) {
    NSLog(@"The terms of service and privacy policy URLs for your app must be provided together. Pl"
        "ease set the terms of service policy using [FUIAuth defaultAuthUI].TOSURL and the privacy"
        " policy URL using [FUIAuth defaultAuthUI].privacyPolicyURL");
    return nil;
  }
  NSString *termsOfServiceString = FUILocalizedString(kStr_TermsOfService);
  NSString *privacyPolicyString = FUILocalizedString(kStr_PrivacyPolicy);
  NSString *privacyPolicyAndTOSString =
      [NSString stringWithFormat:format, termsOfServiceString, privacyPolicyString];
  NSMutableAttributedString *attributedLinkText = nil;
    
  if (@available(iOS 13.0, *)) {
    attributedLinkText = [[NSMutableAttributedString alloc] initWithString:privacyPolicyAndTOSString
                                                                attributes:@{NSForegroundColorAttributeName: [UIColor labelColor]}];
  } else {
    attributedLinkText = [[NSMutableAttributedString alloc] initWithString:privacyPolicyAndTOSString];
  }

  NSRange TOSRange = [privacyPolicyAndTOSString rangeOfString:termsOfServiceString];
  if (TOSRange.length) {
    [attributedLinkText addAttribute:NSLinkAttributeName value:TOSURL range:TOSRange];
  }

  NSRange privacyPolicyRange = [privacyPolicyAndTOSString rangeOfString:privacyPolicyString];
  if (privacyPolicyRange.length) {
    [attributedLinkText addAttribute:NSLinkAttributeName
                               value:privacyPolicyURL
                               range:privacyPolicyRange];
  }
  return attributedLinkText;
}

#pragma mark - Private

- (NSAttributedString *)fullPrivacyPolicyAndTOSMessage {
  return [self privacyPolicyAndTOSMessageFromFormat:FUILocalizedString(kStr_TermsOfServiceMessage)];
}

- (NSAttributedString *)footerPrivacyPolicyAndTOSMessage {
  return [self privacyPolicyAndTOSMessageFromFormat:@"%@    %@"];
}

@end

NS_ASSUME_NONNULL_END
