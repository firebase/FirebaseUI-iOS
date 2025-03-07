import SwiftUI

public class WarningViewConfiguration {
  public var warningMessage: String
  public var textMessage: String
  public var messageFont: Font
  public var buttonFont: Font
  public var buttonBackgroundColor: Color
  public var buttonForegroundColor: Color
  public var buttonCornerRadius: CGFloat
  public var viewBackgroundColor: Color
  public var viewCornerRadius: CGFloat
  public var shadowRadius: CGFloat
  public var strokeColor: Color
  public var strokeLineWidth: CGFloat
  public var frameWidth: CGFloat
  public var frameHeight: CGFloat

  public init(warningMessage: String = "Incorrect email address",
              textMessage: String = "OK",
              messageFont: Font = .headline,
              buttonFont: Font = .body,
              buttonBackgroundColor: Color = .blue,
              buttonForegroundColor: Color = .white,
              buttonCornerRadius: CGFloat = 8,
              viewBackgroundColor: Color = .white,
              viewCornerRadius: CGFloat = 12,
              shadowRadius: CGFloat = 10,
              strokeColor: Color = .gray,
              strokeLineWidth: CGFloat = 1,
              frameWidth: CGFloat = 300,
              frameHeight: CGFloat = 150) {
    self.warningMessage = warningMessage
    self.textMessage = textMessage
    self.messageFont = messageFont
    self.buttonFont = buttonFont
    self.buttonBackgroundColor = buttonBackgroundColor
    self.buttonForegroundColor = buttonForegroundColor
    self.buttonCornerRadius = buttonCornerRadius
    self.viewBackgroundColor = viewBackgroundColor
    self.viewCornerRadius = viewCornerRadius
    self.shadowRadius = shadowRadius
    self.strokeColor = strokeColor
    self.strokeLineWidth = strokeLineWidth
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight
  }
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
