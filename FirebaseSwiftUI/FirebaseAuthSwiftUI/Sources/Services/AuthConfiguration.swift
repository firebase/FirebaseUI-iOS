// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import FirebaseAuth
import Foundation

public struct AuthConfiguration {
  public let shouldHideCancelButton: Bool
  public let interactiveDismissEnabled: Bool
  public let shouldAutoUpgradeAnonymousUsers: Bool
  public let customStringsBundle: Bundle?
  public let tosUrl: URL?
  public let privacyPolicyUrl: URL?
  public let emailLinkSignInActionCodeSettings: ActionCodeSettings?
  public let verifyEmailActionCodeSettings: ActionCodeSettings?

  public init(shouldHideCancelButton: Bool = false,
              interactiveDismissEnabled: Bool = true,
              shouldAutoUpgradeAnonymousUsers: Bool = false,
              customStringsBundle: Bundle? = nil,
              tosUrl: URL? = nil,
              privacyPolicyUrl: URL? = nil,
              emailLinkSignInActionCodeSettings: ActionCodeSettings? = nil,
              verifyEmailActionCodeSettings: ActionCodeSettings? = nil) {
    self.shouldHideCancelButton = shouldHideCancelButton
    self.interactiveDismissEnabled = interactiveDismissEnabled
    self.shouldAutoUpgradeAnonymousUsers = shouldAutoUpgradeAnonymousUsers
    self.customStringsBundle = customStringsBundle
    self.tosUrl = tosUrl
    self.privacyPolicyUrl = privacyPolicyUrl
    self.emailLinkSignInActionCodeSettings = emailLinkSignInActionCodeSettings
    self.verifyEmailActionCodeSettings = verifyEmailActionCodeSettings
  }
}
