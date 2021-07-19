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

#import <UIKit/UIKit.h>

@class FUIAuth;

NS_ASSUME_NONNULL_BEGIN

@interface FUIPrivacyAndTermsOfServiceView : UITextView

/** @fn useFullMessage
    @brief Display Privacy and Terms of Service message in full form.
 */
- (void)useFullMessage;

/** @fn useFooterMessage
    @brief Display Privacy and Terms of Service link, which usually are placed as footer.
 */
- (void)useFooterMessage;

/** @property authUI
    @brief the @c FUIAuth instance whose bundle will be used to populate the view's terms of service and
        privacy policy content. If this property is nil, the default @c FUIAuth instance's terms of service and
        privacy policy will be used.
 */
@property(nonatomic, strong, nullable) FUIAuth *authUI;

@end

@interface FUIPrivacyAndTermsOfServiceView (Protected)

/** @fn privacyPolicyAndTOSMessageFromFormat:
    @brief produce the Privacy and Terms of Service attributed string based on a customized format.
    @param format the customized format with two placeholder for Privacy and Terms of Service
           respectively.
    @return the Privacy and Terms of Service attributed string.
 */
- (nullable NSAttributedString *)privacyPolicyAndTOSMessageFromFormat:(NSString *)format;

@end

NS_ASSUME_NONNULL_END
