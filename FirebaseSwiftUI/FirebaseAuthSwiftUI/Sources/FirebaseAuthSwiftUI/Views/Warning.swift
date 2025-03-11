import SwiftUI

public struct WarningView: View {
  @EnvironmentObject var internalState: FUIAuthState
  private let warningMessage: String
  private let textMessage: String

  public init(warningMessage: String = "Incorrect email address",
              textMessage: String = "OK") {
    self.warningMessage = warningMessage
    self.textMessage = textMessage
  }

  public var body: some View {
    VStack {
      Button(action: {
        internalState.dismissEmailWarning()
      }) {
        Text(warningMessage)
          .font(.body)
          .padding()
          .foregroundColor(.white)
      }
      .padding()
      .background(Color.blue)
      .cornerRadius(8)
    }
    .frame(width: 300, height: 150)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 10)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.gray, lineWidth: 1)
    )
    .padding()
  }
}
