import Foundation

public final class AuthConfiguration {
  var shouldHideCancelButton: Bool
  var interactiveDismissEnabled: Bool
  var shouldAutoUpgradeAnonymousUsers: Bool
  var customStringsBundle: Bundle?
  var tosUrl: URL
  var privacyPolicyUrl: URL

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
