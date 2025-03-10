import SwiftUI

// main auth view - can be composed of custom views or fallback to default views. We can also pass
// state upwards as opposed to having callbacks.
// Negates the need for a delegate used in UIKit
public struct FUIAuthView<Content: View>: View {
  private var authFUI: FUIAuth
  private var authPickerView: AuthPickerView<Content>

  public init(FUIAuth: FUIAuth,
              authPickerView: AuthPickerView<Content>) {
    authFUI = FUIAuth
    self.authPickerView = authPickerView
  }

  public var body: some View {
    authPickerView
  }
}
