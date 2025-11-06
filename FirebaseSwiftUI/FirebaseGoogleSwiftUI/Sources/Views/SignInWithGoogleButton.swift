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

//
//  SignInWithGoogleButton.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 22/05/2025.
//
import FirebaseAuthSwiftUI
import FirebaseAuthUIComponents
import FirebaseCore
import SwiftUI

@MainActor
public struct SignInWithGoogleButton {
  @Environment(AuthService.self) private var authService
  @Environment(\.accountConflictHandler) private var accountConflictHandler
  let googleProvider: AuthProviderSwift

  public init(googleProvider: AuthProviderSwift) {
    self.googleProvider = googleProvider
  }
}

extension SignInWithGoogleButton: View {
  public var body: some View {
    AuthProviderButton(
      label: authService.string.googleLoginButtonLabel,
      style: .google,
      accessibilityId: "sign-in-with-google-button"
    ) {
      Task {
        do {
          _ = try await authService.signIn(googleProvider)
        } catch let AuthServiceError.accountConflict(context) {
          accountConflictHandler(context)
        } catch {
          // Other errors handled by .errorAlert()
        }
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let googleProvider = GoogleProviderSwift(clientID: "")
  return SignInWithGoogleButton(googleProvider: googleProvider)
    .environment(AuthService())
}
