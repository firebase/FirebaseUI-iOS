import FirebaseAuthSwiftUI
import SwiftUI

public struct EmailEntryView: View {
  @State private var email: String = ""
  @EnvironmentObject var internalState: FUIAuthState
  @EnvironmentObject var authFUI: FUIAuth

  public var body: some View {
    if internalState.isEmailWarningVisible {
      WarningView()
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
    }

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
    // TODO: - need to pass in email auth provider
    //    var emailAuthProvider = authFUI.getEmailProvider()
    if !EmailUtils.isValidEmail(email) {
      internalState.showEmailWarning()
    }
  }
}
