import SwiftUI

public struct EmailAuthButton: View {
  @State private var emailAuthView = false
  public var buttonText: String
  public var buttonModifier: (Button<Text>) -> Button<Text>
  public var textModifier: (Text) -> Text
  public var vStackModifier: (VStack<TupleView<(
    Text,
    Button<Text>,
    NavigationLink<EmptyView, EmailEntryView>
  )>>) -> VStack<TupleView<(Text, Button<Text>, NavigationLink<EmptyView, EmailEntryView>)>>

  public init(buttonText: String = "Sign in with email",
              buttonModifier: ((Button<Text>) -> Button<Text>)? = nil,
              textModifier: ((Text) -> Text)? = nil,
              vStackModifier: ((VStack<TupleView<(
                Text,
                Button<Text>,
                NavigationLink<EmptyView, EmailEntryView>
              )>>) -> VStack<TupleView<(
                Text,
                Button<Text>,
                NavigationLink<EmptyView, EmailEntryView>
              )>>)? = nil) {
    self.buttonText = buttonText
    self.buttonModifier = buttonModifier ?? { button in
      button
        .font(.body)
        .padding(8)
        .background(.red)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
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
        .padding() as! VStack<TupleView<(
          Text,
          Button<Text>,
          NavigationLink<EmptyView, EmailEntryView>
        )>>
    }
  }

  public var body: some View {
    let content = VStack {
      textModifier(Text(buttonText))
      buttonModifier(Button(action: {
        emailAuthView = true
      }) {
        Text(buttonText)
      })
      NavigationLink(destination: EmailEntryView(), isActive: $emailAuthView) {
        EmptyView()
      }
    }

    vStackModifier(content)
  }
}
