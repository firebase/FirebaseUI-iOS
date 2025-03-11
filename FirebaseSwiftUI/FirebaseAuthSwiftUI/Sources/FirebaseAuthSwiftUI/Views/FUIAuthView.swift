import SwiftUI

// main auth view - uses FUIAuthState to control what views to display as to hide state from
// consumer
// Negates the need for a delegate used in UIKit
public struct FUIAuthView<Content: View>: View {
  private var authFUI: FUIAuth
  private var authPickerView: AuthPickerView<Content>?
  @ObservedObject var internalState: FUIAuthState = .init()

  public init(FUIAuth: FUIAuth,
              authPickerView: AuthPickerView<Content>? = nil) {
    authFUI = FUIAuth
    self.authPickerView = authPickerView
  }

  public var body: some View {
    if authPickerView != nil {
      authPickerView.environmentObject(internalState).environmentObject(authFUI)
    } else {
      VStack {
        // TODO: - default provider flows to render
      }
    }
  }
}
