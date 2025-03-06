import SwiftUI

// main auth view - can be composed of custom views or fallback to default views. We can also pass
// state upwards as opposed to having callbacks.
// Negates the need for a delegate used in UIKit
public struct FUIAuthView<Modifier: ViewModifier>: View {
  private var authFUI: FUIAuth
  private var authPickerView: AuthPickerView<Modifier>

  public init(FUIAuth: FUIAuth,
              _authPickerView: AuthPickerView<Modifier>? = nil) {
    authFUI = FUIAuth
    authPickerView = _authPickerView ?? AuthPickerView()
  }

  public var body: some View {
    VStack {
      AnyView(authPickerView)
    }
  }
}
