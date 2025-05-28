//
//  SignInWithGoogleButton.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 22/05/2025.
//
import FirebaseAuthSwiftUI
import FirebaseCore
import GoogleSignInSwift
import SwiftUI

@MainActor
public struct SignInWithGoogleButton {
  @Environment(AuthService.self) private var authService

  let customViewModel = GoogleSignInButtonViewModel(
    scheme: .light,
    style: .wide,
    state: .normal
  )
}

extension SignInWithGoogleButton: View {
  public var body: some View {
    GoogleSignInButton(viewModel: customViewModel) {
      Task {
        try await authService.signInWithGoogle()
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return SignInWithGoogleButton()
    .environment(AuthService())
}
