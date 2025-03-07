import SwiftUI

public protocol AuthPickerViewProtocol: View {
  var title: AnyView { get }
}

public struct AuthPickerModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .padding(20)
      .background(Color.white)
      .cornerRadius(12)
      .shadow(radius: 10)
      .padding()
  }
}

public struct AuthPickerView<Modifier: ViewModifier>: AuthPickerViewProtocol {
  // TODO: - this needs either refactoring or needs a generic type to be extended by EmailAuthButton. EmailAuthButton is currently in FUIAuth but needs to be moved
  private var emailAuthButton: EmailAuthButton
  private var vStackModifier: Modifier

  public init(title _: String? = nil, _emailAuthButton: EmailAuthButton? = nil,
              _modifier: Modifier? = nil) {
    emailAuthButton = _emailAuthButton ?? EmailAuthButton()
    vStackModifier = _modifier ?? AuthPickerModifier() as! Modifier
  }

  public var body: some View {
    VStack {
      title
      emailAuthButton
    }.modifier(vStackModifier)
  }

  // Default implementation that can be overridden
  public var title: AnyView {
    AnyView(
      Text("Auth Picker view")
        .font(.largeTitle)
        .padding()
    )
  }
}
