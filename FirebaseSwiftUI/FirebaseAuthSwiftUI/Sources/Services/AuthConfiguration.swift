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
