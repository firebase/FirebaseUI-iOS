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
        LabeledContent {
          TextField("Enter phone number", text: $phoneNumber)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .submitLabel(.next)
        } label: {
          Image(systemName: "at")
        }.padding(.vertical, 6)
          .background(Divider(), alignment: .bottom)
          .padding(.bottom, 4)
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
        }, label: {
          Text("Send SMS code")
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        })
        .disabled(!PhoneUtils.isValidPhoneNumber(phoneNumber))
        .padding([.top, .bottom], 8)
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderedProminent)
        Text(errorMessage).foregroundColor(.red)
      }.sheet(isPresented: $showVerificationCodeInput) {
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
        }, label: {
          Text("Verify phone number and sign-in")
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .cornerRadius(8)
            .padding(.horizontal)
        })
      }.onOpenURL { url in
        authService.auth.canHandle(url)
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
