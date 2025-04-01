import Foundation

public final class AuthConfiguration {
  let shouldHideCancelButton: Bool
  let interactiveDismissEnabled: Bool
  let shouldAutoUpgradeAnonymousUsers: Bool
  let customStringsBundle: Bundle?
  let tosUrl: URL
  let privacyPolicyUrl: URL

  public init(shouldHideCancelButton: Bool = false,
              interactiveDismissEnabled: Bool = true,
              shouldAutoUpgradeAnonymousUsers: Bool = false,
              customStringsBundle: Bundle? = nil,
              tosUrl: URL = URL(string: "https://example.com/tos")!,
              privacyPolicyUrl: URL = URL(string: "https://example.com/privacy")!) {
    self.shouldHideCancelButton = shouldHideCancelButton
    self.interactiveDismissEnabled = interactiveDismissEnabled
    self.shouldAutoUpgradeAnonymousUsers = shouldAutoUpgradeAnonymousUsers
    self.customStringsBundle = customStringsBundle
    self.tosUrl = tosUrl
    self.privacyPolicyUrl = privacyPolicyUrl
  }
}
