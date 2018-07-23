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

#import "FUIPrivacyAndTermsOfServiceView+PhoneAuth.h"

#import "FUIAuth.h"
#import "FUIAuthStrings.h"
#import "FUIPhoneAuthStrings.h"

@implementation FUIPrivacyAndTermsOfServiceView (PhoneAuth)

- (void)useFullMessageWithSMSRateTerm {
  self.textAlignment = NSTextAlignmentLeft;
  NSMutableAttributedString *fullMessage =
      [[self fullPrivacyPolicyAndTOSMessageWithSMSRateInfo] mutableCopy];
  self.attributedText = fullMessage;
}

#pragma mark - Private

- (NSAttributedString *)fullPrivacyPolicyAndTOSMessageWithSMSRateInfo {
  NSString *messageFormat =
      [NSString stringWithFormat:FUIPhoneAuthLocalizedString(kPAStr_TermsSMS),
          FUIPhoneAuthLocalizedString(kPAStr_Verify), @"%@", @"%@"];
  return [self privacyPolicyAndTOSMessageFromFormat:messageFormat];


}

@end
