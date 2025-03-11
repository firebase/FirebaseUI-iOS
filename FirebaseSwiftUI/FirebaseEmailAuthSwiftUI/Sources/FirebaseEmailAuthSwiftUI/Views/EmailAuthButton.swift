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

public struct EmailAuthButton<ButtonStyleType: ButtonStyle>: View {
  @State private var emailAuthView = false
  private var buttonText: String
  private var buttonStyle: ButtonStyleType

  public init(buttonText: String = "Sign in with email", buttonStyle: ButtonStyleType) {
    self.buttonText = buttonText
    self.buttonStyle = buttonStyle
  }

  public var body: some View {
    let textView = Text(buttonText)

    let buttonView = Button(action: {
      emailAuthView = true
    }) {
      textView
    }

    buttonView.buttonStyle(buttonStyle)
  }
}
