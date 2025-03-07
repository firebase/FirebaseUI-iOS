import SwiftUI

// main auth view - can be composed of custom views or fallback to default views. We can also pass
// state upwards as opposed to having callbacks.
// Negates the need for a delegate used in UIKit
public struct FUIAuthView: View {
  private var authFUI: FUIAuth
  private var authPickerView: AuthPickerView

  public init(FUIAuth: FUIAuth,
              _authPickerView: AuthPickerView? = nil) {
    authFUI = FUIAuth
    authPickerView = _authPickerView ?? AuthPickerView()
  }

  public var body: some View {
    VStack {
      authPickerView
    }
  }
}
