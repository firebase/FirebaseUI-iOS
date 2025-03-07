import SwiftUI

// TODO: - needs to be moved to EmailAuth package.
public struct EmailEntryView: View {
  @State private var email: String = ""
  @State private var invalidEmailWarning: Bool = false
  @EnvironmentObject var authFUI: FUIAuth

  public var body: some View {
    if invalidEmailWarning {
      WarningView(
        invalidEmailWarning: $invalidEmailWarning,
        message: "Incorrect email address",
        configuration: WarningViewConfiguration()
      )
    } else {
      VStack {
        Text("Email")
          .font(.largeTitle)
          .padding()
        TextField("Email", text: $email, onCommit: emailSubmit)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()
      }
      .padding(20)
      .background(Color.white)
      .cornerRadius(12)
      .shadow(radius: 10)
      .padding()
      // TODO: - figure out why this is causing exception: Ambiguous use of 'toolbar(content:)'
      //    .toolbar {
      //      ToolbarItemGroup(placement: .navigationBarTrailing) {
      //        Button("Next") {
      //          handleNext()
      //        }
      //      }
      //    }
    }
  }

  private func emailSubmit() {
//    var emailAuthProvider = authFUI.getEmailProvider()
    if !AuthUtils.isValidEmail(email) {
      invalidEmailWarning = true
    }
  }
}
