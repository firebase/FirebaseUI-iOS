import SwiftUI

public struct WarningView: View {
  @Binding var invalidEmailWarning: Bool
  private let warningMessage: String
  private let textMessage: String
  private let messageModifier: (Text) -> Text
  private let buttonModifier: (Button<Text>) -> Button<Text>
  private let vStackModifier: (VStack<TupleView<(Text, Button<Text>)>>) -> VStack<TupleView<(
    Text,
    Button<Text>
  )>>

  public init(invalidEmailWarning: Binding<Bool>,
              warningMessage: String = "Incorrect email address",
              textMessage: String = "OK",
              messageModifier: ((Text) -> Text)? = nil,
              buttonModifier: ((Button<Text>) -> Button<Text>)? = nil,
              vStackModifier: ((VStack<TupleView<(Text, Button<Text>)>>) -> VStack<TupleView<(
                Text,
                Button<Text>
              )>>)? = nil) {
    _invalidEmailWarning = invalidEmailWarning
    self.warningMessage = warningMessage
    self.textMessage = textMessage
    self.messageModifier = messageModifier ?? { text in
      text
        .font(.headline)
        .padding() as! Text
    }
    self.buttonModifier = buttonModifier ?? { button in
      button
        .font(.body)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8) as! Button<Text>
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
        .padding() as! VStack<TupleView<(Text, Button<Text>)>>
    }
  }

  public var body: some View {
    let content = VStack {
      messageModifier(Text(warningMessage))
      buttonModifier(Button(action: {
        invalidEmailWarning = false
      }) {
        Text(textMessage)
      })
    }

    vStackModifier(content)
  }
}
