import SwiftUI

public struct EmailAuthButton: View {
  @State private var emailAuthView = false
  public var buttonText: String
  public var buttonModifier: (Button<Text>) -> Button<Text>?
  public var textModifier: (Text) -> Text
  public var vStackModifier: (VStack<TupleView<(
    Button<Text>,
    NavigationLink<EmptyView, EmailEntryView>
  )>>) -> VStack<TupleView<(Button<Text>, NavigationLink<EmptyView, EmailEntryView>)>>

  public init(buttonText: String = "Sign in with email",
              buttonModifier: ((Button<Text>) -> Button<Text>)? = nil,
              textModifier: ((Text) -> Text)? = nil,
              vStackModifier: ((VStack<TupleView<(
                Button<Text>,
                NavigationLink<EmptyView, EmailEntryView>
              )>>) -> VStack<TupleView<(
                Button<Text>,
                NavigationLink<EmptyView, EmailEntryView>
              )>>)? = nil) {
    self.buttonText = buttonText
    self.buttonModifier = buttonModifier
    self.textModifier = textModifier ?? { text in
      text
        .font(.headline)
        .padding() as! Text
    }
    self.vStackModifier = vStackModifier ?? { vstack in
      vstack
        .frame(width: 300, height: 150)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray, lineWidth: 1)
        )
        .padding() as! VStack<TupleView<(Button<Text>, NavigationLink<EmptyView, EmailEntryView>)>>
    }
  }

  public var body: some View {
    let buttonView: Button<Text> = {
      let button = Button(action: {
        emailAuthView = true
      }) {
        textModifier(Text(buttonText))
      }

      if let customButtonModifier = buttonModifier {
        return customButtonModifier(button)
      } else {
        return button
          .font(.body)
          .padding(8)
          .background(.red)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
    }()

    let content = VStack {
      buttonView
      NavigationLink(destination: EmailEntryView(), isActive: $emailAuthView) {
        EmptyView()
      }
    }

    return vStackModifier(content)
  }
}
