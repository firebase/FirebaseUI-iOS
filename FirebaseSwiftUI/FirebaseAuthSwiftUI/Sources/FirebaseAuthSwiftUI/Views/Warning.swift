import SwiftUI

// Base class with default values that can be overridden by user
public class WarningViewConfiguration {
  public var warningMessage: String = "Incorrect email address"
  public var textMessage: String = "OK"
  public var messageFont: Font = .headline
  public var buttonFont: Font = .body
  public var buttonBackgroundColor: Color = .blue
  public var buttonForegroundColor: Color = .white
  public var buttonCornerRadius: CGFloat = 8
  public var viewBackgroundColor: Color = .white
  public var viewCornerRadius: CGFloat = 12
  public var shadowRadius: CGFloat = 10
  public var strokeColor: Color = .gray
  public var strokeLineWidth: CGFloat = 1
  public var frameWidth: CGFloat = 300
  public var frameHeight: CGFloat = 150

  public init() {}
}

public struct WarningView: View {
  @Binding var invalidEmailWarning: Bool
  var configuration: WarningViewConfiguration

  public var body: some View {
    VStack {
      Text(configuration.warningMessage)
        .font(configuration.messageFont)
        .padding()
      Button(action: {
        invalidEmailWarning = false
      }) {
        Text(configuration.textMessage)
          .font(configuration.buttonFont)
          .padding()
          .background(configuration.buttonBackgroundColor)
          .foregroundColor(configuration.buttonForegroundColor)
          .cornerRadius(configuration.buttonCornerRadius)
      }
    }
    .frame(width: configuration.frameWidth, height: configuration.frameHeight)
    .background(configuration.viewBackgroundColor)
    .cornerRadius(configuration.viewCornerRadius)
    .shadow(radius: configuration.shadowRadius)
    .overlay(
      RoundedRectangle(cornerRadius: configuration.viewCornerRadius)
        .stroke(configuration.strokeColor, lineWidth: configuration.strokeLineWidth)
    )
    .padding()
  }
}
