import SwiftUI

public class FUIAuthState: ObservableObject {
  @Published public var isEmailWarningVisible: Bool = false

  public func dismissEmailWarning() {
    isEmailWarningVisible = false
  }

  public func showEmailWarning() {
    isEmailWarningVisible = true
  }
}
