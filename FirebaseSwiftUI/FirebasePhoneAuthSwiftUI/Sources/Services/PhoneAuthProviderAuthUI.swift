// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import SwiftUI

public typealias VerificationID = String

public class PhoneProviderSwift: PhoneAuthProviderSwift {
  public init() {}

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

  @MainActor public func createAuthCredential() async throws -> AuthCredential {
    fatalError("Not implemented")
  }

  @MainActor public func createAuthCredential(verificationId: String,
                                              verificationCode: String) async throws
    -> AuthCredential {
    return PhoneAuthProvider.provider()
      .credential(withVerificationID: verificationId, verificationCode: verificationCode)
  }
}

public class PhoneAuthProviderAuthUI: AuthProviderUI {
  public var provider: AuthProviderSwift
  public let id: String = "phone"

  public init(provider: PhoneAuthProviderSwift? = nil) {
    self.provider = provider ?? PhoneProviderSwift()
  }

  @MainActor public func authButton() -> AnyView {
    AnyView(PhoneAuthButtonView(phoneProvider: provider as! PhoneAuthProviderSwift))
  }
}
