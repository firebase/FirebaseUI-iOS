import SwiftUI

public struct PasswordRecoveryView: View {
  @State private var email = ""
  public var body: some View {
    VStack {
      Text("Password Recovery")
      LabeledContent {
        TextField("Email", text: $email)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .submitLabel(.next)
      } label: {
        Image(systemName: "at")
      }.padding(.vertical, 6)
        .background(Divider(), alignment: .bottom)
        .padding(.bottom, 4)
    }
  }
}
