import SwiftUI

public struct EmailAuthButtonModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .font(.body)
      .padding(8)
      .background(Color.red)
      .foregroundColor(Color.white)
      .cornerRadius(8)
  }
}

public struct EmailAuthVStackModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .frame(width: 300, height: 150)
      .background(Color.white)
      .cornerRadius(12)
      .shadow(radius: 10)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.gray, lineWidth: 1)
      )
      .padding()
  }
}

public struct EmailAuthTextModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .font(.headline)
      .padding()
  }
}

public struct EmailAuthButton<
  ButtonModifier: ViewModifier,
  ButtonTextModifier: ViewModifier,
  VStackModifier: ViewModifier
>: View {
  @State private var emailAuthView = false
  private var buttonText: String
  private var buttonModifier: ButtonModifier?
  private var buttonTextModifier: ButtonTextModifier?
  private var vStackModifier: VStackModifier?

  public init(buttonText: String = "Sign in with email", buttonModifier: ButtonModifier? = nil,
              buttonTextModifier: ButtonTextModifier? = nil,
              vStackModifier: VStackModifier? = nil) {
    self.buttonText = buttonText
    self.buttonModifier = buttonModifier
    self.buttonTextModifier = buttonTextModifier
    self.vStackModifier = vStackModifier
  }

  public var body: some View {
    let textView = Text(buttonText)
      .modifier(buttonTextModifier ?? EmailAuthTextModifier() as! ButtonTextModifier)

    let buttonView = Button(action: {
      emailAuthView = true
    }) {
      textView
    }.modifier(buttonModifier ?? EmailAuthButtonModifier() as! ButtonModifier)

    return VStack {
      buttonView
      NavigationLink(destination: EmailEntryView(), isActive: $emailAuthView) {
        EmptyView()
      }
    }.modifier(vStackModifier ?? EmailAuthVStackModifier() as! VStackModifier)
  }
}
