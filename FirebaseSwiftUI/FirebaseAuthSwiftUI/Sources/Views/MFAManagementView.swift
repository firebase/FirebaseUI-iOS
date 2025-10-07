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

import FirebaseAuth
import SwiftUI

@MainActor
public struct MFAManagementView {
  @Environment(AuthService.self) private var authService

  @State private var enrolledFactors: [MultiFactorInfo] = []
  @State private var isLoading = false
  @State private var errorMessage = ""

  // Present password prompt when required for reauthentication
  private var isShowingPasswordPrompt: Binding<Bool> {
    Binding(
      get: { authService.passwordPrompt.isPromptingPassword },
      set: { authService.passwordPrompt.isPromptingPassword = $0 }
    )
  }

  public init() {}

  private func loadEnrolledFactors() {
    guard let user = authService.currentUser else { return }
    enrolledFactors = user.multiFactor.enrolledFactors
  }

  private func unenrollFactor(_ factorUid: String) {
    Task {
      isLoading = true
      errorMessage = ""

      do {
        let freshFactors = try await authService.unenrollMFA(factorUid)
        enrolledFactors = freshFactors
      } catch {
        errorMessage = error.localizedDescription
      }

      isLoading = false
    }
  }

  private func navigateToEnrollment() {
    authService.authView = .mfaEnrollment
  }

  private func goBack() {
    authService.authView = .authPicker
  }
}

extension MFAManagementView: View {
  public var body: some View {
    VStack(spacing: 20) {
      // Header with manual back button
      HStack {
        Button(action: {
          authService.authView = .authPicker
        }) {
          HStack(spacing: 4) {
            Image(systemName: "chevron.left")
              .font(.system(size: 17, weight: .medium))
            Text(authService.string.backButtonLabel)
              .font(.system(size: 17))
          }
          .foregroundColor(.blue)
        }
        .accessibilityIdentifier("back-button")

        Spacer()
      }
      .padding(.horizontal)

      // Title section
      VStack {
        Text("Two-Factor Authentication")
          .font(.largeTitle)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Text("Manage your authentication methods")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
      .padding(.horizontal)

      if enrolledFactors.isEmpty {
        // No factors enrolled
        VStack(spacing: 16) {
          Image(systemName: "shield.slash")
            .font(.system(size: 48))
            .foregroundColor(.orange)

          Text("No Authentication Methods")
            .font(.title2)
            .fontWeight(.semibold)

          Text(
            "Set up two-factor authentication to add an extra layer of security to your account."
          )
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)

          Button("Set Up Two-Factor Authentication") {
            navigateToEnrollment()
          }
          .buttonStyle(.borderedProminent)
          .accessibilityIdentifier("setup-mfa-button")
        }
      } else {
        // Show enrolled factors
        VStack(alignment: .leading, spacing: 16) {
          Text("Enrolled Methods")
            .font(.headline)
            .padding(.horizontal)

          ForEach(enrolledFactors, id: \.uid) { factor in
            factorRow(factor: factor)
          }

          Divider()
            .padding(.horizontal)

          Button("Add Another Method") {
            navigateToEnrollment()
          }
          .buttonStyle(.bordered)
          .padding(.horizontal)
          .accessibilityIdentifier("add-mfa-method-button")
        }
      }

      // Error message
      if !errorMessage.isEmpty {
        Text(errorMessage)
          .foregroundColor(.red)
          .font(.caption)
          .padding(.horizontal)
          .accessibilityIdentifier("error-message")
      }

      Spacer()
    }
    .onAppear {
      loadEnrolledFactors()
    }
    .sheet(isPresented: isShowingPasswordPrompt) {
      PasswordPromptSheet(coordinator: authService.passwordPrompt)
    }
  }

  @ViewBuilder
  private func factorRow(factor: MultiFactorInfo) -> some View {
    HStack {
      // Factor type icon
      Group {
        if factor.factorID == PhoneMultiFactorID {
          Image(systemName: "message")
            .foregroundColor(.blue)
        } else {
          Image(systemName: "qrcode")
            .foregroundColor(.green)
        }
      }
      .font(.title2)

      VStack(alignment: .leading, spacing: 4) {
        Text(factor.displayName ?? "Unnamed Method")
          .font(.headline)

        if factor.factorID == PhoneMultiFactorID {
          let phoneInfo = factor as! PhoneMultiFactorInfo
          Text("SMS: \(phoneInfo.phoneNumber)")
            .font(.caption)
            .foregroundColor(.secondary)
        } else {
          Text("Authenticator App")
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Text("Enrolled: \(DateFormatter.shortDate.string(from: factor.enrollmentDate))")
          .font(.caption2)
          .foregroundColor(.secondary)
      }

      Spacer()

      Button("Remove") {
        unenrollFactor(factor.uid)
      }
      .buttonStyle(.bordered)
      .foregroundColor(.red)
      .disabled(isLoading)
      .accessibilityIdentifier("remove-factor-\(factor.uid)")
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(8)
    .padding(.horizontal)
  }
}

// MARK: - Date Formatter Extension

private extension DateFormatter {
  static let shortDate: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
  }()
}

#Preview {
  MFAManagementView()
    .environment(AuthService())
}
