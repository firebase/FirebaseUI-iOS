import SwiftUI

public class AuthPickerViewConfiguration {
  public var title: String
  public var titleFont: Font
  public var titlePadding: CGFloat
  public var backgroundColor: Color
  public var cornerRadius: CGFloat
  public var shadowRadius: CGFloat

  // Custom initializer
  public init(title: String = "Auth Picker view",
              titleFont: Font = .largeTitle,
              titlePadding: CGFloat = 20,
              backgroundColor: Color = .white,
              cornerRadius: CGFloat = 12,
              shadowRadius: CGFloat = 10) {
    self.title = title
    self.titleFont = titleFont
    self.titlePadding = titlePadding
    self.backgroundColor = backgroundColor
    self.cornerRadius = cornerRadius
    self.shadowRadius = shadowRadius
  }
}

public protocol AuthPickerViewProtocol: View {
  var configuration: AuthPickerViewConfiguration { get }
}

public struct AuthPickerView: AuthPickerViewProtocol {
  public let configuration: AuthPickerViewConfiguration

  public init(configuration: AuthPickerViewConfiguration = AuthPickerViewConfiguration()) {
    self.configuration = configuration
  }

  public var body: some View {
    VStack {
      Text(configuration.title)
        .font(configuration.titleFont)
        .padding(configuration.titlePadding)
    }
    .padding(configuration.titlePadding)
    .background(configuration.backgroundColor)
    .cornerRadius(configuration.cornerRadius)
    .shadow(radius: configuration.shadowRadius)
    .padding()
  }
}
