//
//  UpdatePassword.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 24/04/2025.
//

import SwiftUI

private enum FocusableField: Hashable {
  case password
  case confirmPassword
}

@MainActor
public struct UpdatePasswordView {
  @Environment(AuthService.self) private var authService
  @State private var password = ""
  @State private var confirmPassword = ""

  @FocusState private var focus: FocusableField?
  private var isValid: Bool {
    !password.isEmpty && password == confirmPassword
  }
}

extension UpdatePasswordView: View {
  private var isShowingPasswordPrompt: Binding<Bool> {
    Binding(
      get: { authService.passwordPrompt.isPromptingPassword },
      set: { authService.passwordPrompt.isPromptingPassword = $0 }
    )
  }

  public var body: some View {
    VStack {
      LabeledContent {
        SecureField("Password", text: $password)
          .focused($focus, equals: .password)
          .submitLabel(.go)
      } label: {
        Image(systemName: "lock")
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 8)

      Divider()

      LabeledContent {
        SecureField("Confirm password", text: $confirmPassword)
          .focused($focus, equals: .confirmPassword)
          .submitLabel(.go)
      } label: {
        Image(systemName: "lock")
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 8)

      Divider()

      Button(action: {
        Task {
          try await authService.updatePassword(to: confirmPassword)
          authService.authView = .authPicker
        }
      }, label: {
        Text("Update password")
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)

      })
      .disabled(!isValid)
      .padding([.top, .bottom], 8)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)
    }.sheet(isPresented: isShowingPasswordPrompt) {
      PasswordPromptSheet(coordinator: authService.passwordPrompt)
    }
  }
}
