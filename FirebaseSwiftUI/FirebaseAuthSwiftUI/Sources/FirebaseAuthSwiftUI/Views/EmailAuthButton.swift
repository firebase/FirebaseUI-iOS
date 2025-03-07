import SwiftUI

public protocol FUIButtonProtocol: View {
  var buttonContent: AnyView { get }
}

public struct EmailAuthButton: FUIButtonProtocol {
  @State private var emailAuthView = false
  public var body: some View {
    VStack {
      // TODO: - update FUIButtonProtocol with ways to align the button/have defaults
      Button(action: {
        emailAuthView = true
      }) {
        buttonContent
      }
      NavigationLink(destination: EmailEntryView(), isActive: $emailAuthView) {
        EmptyView()
      }
    }
  }

  // Default implementation that can be overridden
  public var buttonContent: AnyView {
    AnyView(
      Text("Sign in with email")
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(8)
    )
  }
}
