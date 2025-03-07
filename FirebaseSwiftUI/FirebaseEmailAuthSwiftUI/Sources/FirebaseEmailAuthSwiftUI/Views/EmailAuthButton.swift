import SwiftUI

public protocol FUIButtonProtocol: View {
  var configuration: EmailAuthButtonConfiguration { get }
}

public class EmailAuthButtonConfiguration {
  public var buttonText: String
  public var buttonPadding: CGFloat
  public var buttonBackgroundColor: Color
  public var buttonForegroundColor: Color
  public var buttonCornerRadius: CGFloat

  public init(buttonText: String = "Sign in with email",
              buttonPadding: CGFloat = 8,
              buttonBackgroundColor: Color = .red,
              buttonForegroundColor: Color = .white,
              buttonCornerRadius: CGFloat = 8) {
    self.buttonText = buttonText
    self.buttonPadding = buttonPadding
    self.buttonBackgroundColor = buttonBackgroundColor
    self.buttonForegroundColor = buttonForegroundColor
    self.buttonCornerRadius = buttonCornerRadius
  }
}

public struct EmailAuthButton: FUIButtonProtocol {
  @State private var emailAuthView = false
  public let configuration: EmailAuthButtonConfiguration

  public init(configuration: EmailAuthButtonConfiguration = EmailAuthButtonConfiguration()) {
    self.configuration = configuration
  }

  public var body: some View {
    VStack {
      Button(action: {
        emailAuthView = true
      }) {
        Text(configuration.buttonText)
          .padding(configuration.buttonPadding)
          .background(configuration.buttonBackgroundColor)
          .foregroundColor(configuration.buttonForegroundColor)
          .cornerRadius(configuration.buttonCornerRadius)
      }
      NavigationLink(destination: EmailEntryView(), isActive: $emailAuthView) {
        EmptyView()
      }
    }
  }
}
