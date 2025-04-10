import FirebaseAuthSwiftUI
import SwiftUI

@MainActor
public struct PhoneAuthButtonView {
  @Environment(AuthService.self) private var authService
  @State private var errorMessage = ""
  @State private var phoneNumber = ""
  @State private var showVerificationCodeInput = false
  @State private var verificationCode = ""
  @State private var verificationID = ""

  public init() {}
}

extension PhoneAuthButtonView: View {
  public var body: some View {
    if authService.authenticationState != .authenticating {
      VStack {
        TextField("Enter phone number", text: $phoneNumber)
          .keyboardType(.phonePad)
          .padding()
          .background(Color(.systemGray6))
          .cornerRadius(8)
          .padding(.horizontal)

        Button(action: {
          Task {
            do {
              let id = try await authService.verifyPhoneNumber(phoneNumber: phoneNumber)
              verificationID = id
              showVerificationCodeInput = true
            } catch {
              errorMessage = authService.string.localizedErrorMessage(
                for: error
              )
            }
          }
        }) {
          Text("Send Verification Code")
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(8)
            .padding(.horizontal)
        }.disabled(!PhoneUtils.isValidPhoneNumber(phoneNumber))
      }
      .sheet(isPresented: $showVerificationCodeInput) {
        VStack {
          TextField("Enter verification code", text: $verificationCode)
            .keyboardType(.numberPad)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)

          Button(action: {
            Task {
              do {
                try await authService.signInWithPhoneNumber(
                  verificationID: verificationID,
                  verificationCode: verificationCode
                )
              } catch {
                errorMessage = authService.string.localizedErrorMessage(for: error)
              }
              showVerificationCodeInput = false
            }
          }) {
            Text("Verify and Sign In")
              .foregroundColor(.white)
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color.green)
              .cornerRadius(8)
              .padding(.horizontal)
          }
        }
      }
    } else {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
    Text(errorMessage).foregroundColor(.red)
  }
}
