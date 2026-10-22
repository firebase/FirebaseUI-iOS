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

/// The stock content of ``MFAManagementScreen``.
@MainActor
public struct DefaultMFAManagementContent: View {
  public init(state: MFAManagementContentState) {
    self.state = state
  }

  @Environment(AuthService.self) private var authService
  private let state: MFAManagementContentState

  public var body: some View {
    VStack(spacing: 20) {
      // Title section
      VStack {
        Text("Two-Factor Authentication")
          .authFont(.largeTitle)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Text("Manage your authentication methods")
          .authFont(.subheadline)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
      .padding(.horizontal)

      if state.enrolledFactors.isEmpty {
        // No factors enrolled
        VStack(spacing: 16) {
          Image(systemName: "shield.slash")
            .font(.system(size: 48))
            .foregroundColor(.orange)

          Text("No Authentication Methods")
            .authFont(.title2)
            .fontWeight(.semibold)

          Text(
            "Set up two-factor authentication to add an extra layer of security to your account."
          )
          .authFont(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)

          Button {
            state.goToEnrollment()
          } label: {
            Text("Set Up Two-Factor Authentication")
              .padding(.vertical, 8)
              .frame(maxWidth: .infinity)
          }
          .authCTAButtonStyle()
          .padding([.top, .bottom], 8)
          .frame(maxWidth: .infinity)
          .accessibilityIdentifier("setup-mfa-button")
        }
      } else {
        // Show enrolled factors
        VStack(alignment: .leading, spacing: 16) {
          Text("Enrolled Methods")
            .authFont(.headline)
            .padding(.horizontal)

          ForEach(state.enrolledFactors) { factor in
            factorRow(factor: factor)
          }

          Divider()
            .padding(.horizontal)

          Button("Add Another Method") {
            state.goToEnrollment()
          }
          .padding([.top, .bottom], 8)
          .frame(maxWidth: .infinity)
          .authCTAButtonStyle()
          .accessibilityIdentifier("add-mfa-method-button")
        }
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .safeAreaPadding()
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
      .authFont(.title2)

      VStack(alignment: .leading, spacing: 4) {
        Text(factor.displayName ?? authService.string.unnamedMethodLabel)
          .authFont(.headline)

        if factor.factorID == PhoneMultiFactorID {
          let phoneInfo = factor as! PhoneMultiFactorInfo
          Text("SMS: \(phoneInfo.phoneNumber)")
            .authFont(.caption)
            .foregroundColor(.secondary)
        } else {
          Text("Authenticator App")
            .authFont(.caption)
            .foregroundColor(.secondary)
        }

        Text("Enrolled: \(DateFormatter.shortDate.string(from: factor.enrollmentDate))")
          .authFont(.caption2)
          .foregroundColor(.secondary)
      }

      Spacer()

      Button("Remove") {
        state.unenroll(factor.uid)
      }
      .buttonStyle(.bordered)
      .foregroundColor(.red)
      .disabled(state.isLoading)
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
