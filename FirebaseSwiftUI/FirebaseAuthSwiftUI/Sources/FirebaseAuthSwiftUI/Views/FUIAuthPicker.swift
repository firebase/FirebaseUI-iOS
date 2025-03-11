import SwiftUI

public struct AuthPickerView<Content: View>: View {
  private let content: Content
  private let title: String
  private let textModifier: (Text) -> Text
  private let vStackModifier: (VStack<TupleView<(Text, Content)>>) -> VStack<TupleView<(
    Text,
    Content
  )>>

  public init(title: String = "Auth Picker view",
              textModifier: ((Text) -> Text)? = nil,
              vStackModifier: ((VStack<TupleView<(Text, Content)>>) -> VStack<TupleView<(
                Text,
                Content
              )>>)? = nil,
              @ViewBuilder content: () -> Content) {
    self.title = title
    self.textModifier = textModifier ?? { text in
      text
        .font(.title)
        .foregroundColor(.red)
        .bold()
    }
    self.vStackModifier = vStackModifier ?? { vstack in
      vstack
    }
    self.content = content()
  }

  public var body: some View {
    let titleView = textModifier(Text(title))
    let vStack = VStack {
      titleView
      content
    }

    vStackModifier(vStack)
  }
}
