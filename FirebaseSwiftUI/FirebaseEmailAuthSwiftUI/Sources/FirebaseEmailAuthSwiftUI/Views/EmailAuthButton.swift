import FirebaseAuthSwiftUI
import SwiftUI

public struct DefaultEmailAuthButtonStyle: ButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .background(Color.blue)
      .foregroundColor(.white)
      .cornerRadius(10)
  }
}

public protocol EmailButtonTextStyle {
  associatedtype Body: View

  @ViewBuilder func body(content: Button<Text>) -> Body
}

public struct DefaultEmailButtonTextStyle: EmailButtonTextStyle {
  public init() {}

  public func body(content: Button<Text>) -> some View {
    content
  }
}

public struct EmailAuthButton<
  ButtonStyleType: ButtonStyle,
  ButtonTextStyleType: EmailButtonTextStyle
>: View {
  @State private var emailAuthView = false
  @EnvironmentObject var internalState: FUIAuthState
  @EnvironmentObject var authFUI: FUIAuth
  private var buttonText: String
  private var buttonStyle: ButtonStyleType
  private var buttonTextStyle: ButtonTextStyleType

  public init(buttonText: String = "Sign in with email", buttonStyle: ButtonStyleType,
              buttonTextStyle: ButtonTextStyleType) {
    self.buttonText = buttonText
    self.buttonStyle = buttonStyle
    self.buttonTextStyle = buttonTextStyle
  }

  public var body: some View {
    let textView = Text(buttonText)

    let buttonView = Button(action: {
      emailAuthView = true
    }) {
      textView
    }

    buttonTextStyle.body(content: buttonView).buttonStyle(buttonStyle)
    NavigationLink(
      destination: EmailEntryView().environmentObject(internalState).environmentObject(authFUI),
      isActive: $emailAuthView
    ) {
      EmptyView()
    }
  }
}
