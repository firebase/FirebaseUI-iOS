import SwiftUI

public class AuthPickerViewConfiguration {
  public var title: String = "Auth Picker view"
  public var titleFont: Font = .largeTitle
  public var titlePadding: CGFloat = 20
  public var backgroundColor: Color = .white
  public var cornerRadius: CGFloat = 12
  public var shadowRadius: CGFloat = 10

  public init() {}
}

public protocol AuthPickerViewProtocol {
  var configuration: AuthPickerViewConfiguration { get }
}

public struct AuthPickerView: AuthPickerViewProtocol {
  private let configuration: AuthPickerViewConfiguration

  public init(configuration: AuthPickerViewConfiguration = AuthPickerViewConfiguration()) {
    self.configuration = configuration
  }

  public var body: some View {
    VStack {
      Text(configuration.title)
        .font(configuration.titleFont)
        .padding(configuration.titlePadding)
      EmailAuthButton()
    }
    .padding(configuration.titlePadding)
    .background(configuration.backgroundColor)
    .cornerRadius(configuration.cornerRadius)
    .shadow(radius: configuration.shadowRadius)
    .padding()
  }
}
