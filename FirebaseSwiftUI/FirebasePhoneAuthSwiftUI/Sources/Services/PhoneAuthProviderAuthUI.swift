@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import SwiftUI

public typealias VerificationID = String

public class PhoneAuthProviderAuthUI: @preconcurrency PhoneAuthProviderAuthUIProtocol {
  public let id: String = "phone"

  @MainActor public func authButton() -> AnyView {
    AnyView(PhoneAuthButtonView())
  }

  @MainActor public func verifyPhoneNumber(phoneNumber: String) async throws -> VerificationID {
    return try await withCheckedThrowingContinuation { continuation in
      PhoneAuthProvider.provider()
        .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
          if let error = error {
            continuation.resume(throwing: error)
            return
          }
          continuation.resume(returning: verificationID!)
        }
    }
  }
}
