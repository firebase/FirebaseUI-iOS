import SwiftUI

public protocol FUIVStackStyle {
  associatedtype Body: View

  @ViewBuilder func body(content: VStack<Button<Text>>) -> Body
}

public struct DefaultVStackStyle: FUIVStackStyle {
  public init() {}

  public func body(content: VStack<Button<Text>>) -> some View {
    content
      .padding()
      .background(Color.gray.opacity(0.2))
      .cornerRadius(10)
  }
}

public struct EmailAuthButton<StackStyle: FUIVStackStyle>: View {
  @State private var emailAuthView = false
  private var buttonText: String
  private var vStackStyle: StackStyle?

  public init(buttonText: String = "Sign in with email", vStackStyle: StackStyle? = nil) {
    self.buttonText = buttonText
    self.vStackStyle = vStackStyle
  }

  public var body: some View {
    let textView = Text(buttonText)

    let buttonView = Button(action: {
      emailAuthView = true
    }) {
      textView
    }

    let vStackView = VStack {
      buttonView
    }

    if let vStackStyle = vStackStyle {
      vStackStyle.body(content: vStackView)
    } else {
      DefaultVStackStyle().body(content: vStackView)
    }
  }
}
