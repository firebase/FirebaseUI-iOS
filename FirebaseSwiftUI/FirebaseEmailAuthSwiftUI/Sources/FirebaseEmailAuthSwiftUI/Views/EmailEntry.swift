import FirebaseAuthSwiftUI
import SwiftUI

public struct EmailEntryView: View {
  @State private var email: String = ""
  @State private var invalidEmailWarning: Bool = false
  @EnvironmentObject var authFUI: FUIAuth

  public var body: some View {
    WarningView(
      invalidEmailWarning: $invalidEmailWarning
    ).disabled(invalidEmailWarning == true)

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
    .disabled(invalidEmailWarning == false)
    // TODO: - figure out why this is causing exception: Ambiguous use of 'toolbar(content:)'
//      .toolbar {
//        ToolbarItemGroup(placement: .navigationBarTrailing) {
//          Button("Next") {
//            emailSubmit()
//          }
//        }
//      }
  }

  private func emailSubmit() {
    var emailAuthProvider = authFUI.getEmailProvider()
    if !EmailUtils.isValidEmail(email) {
      invalidEmailWarning = true
    }
  }
}
