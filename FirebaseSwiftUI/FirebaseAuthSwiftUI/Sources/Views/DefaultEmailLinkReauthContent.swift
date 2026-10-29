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

import FirebaseAuthUIComponents
import SwiftUI

/// The stock content of ``EmailLinkReauthScreen``.
@MainActor
public struct DefaultEmailLinkReauthContent: View {
  public init(state: EmailLinkReauthContentState) {
    self.state = state
  }

  private let state: EmailLinkReauthContentState

  public var body: some View {
    VStack(spacing: 24) {
      if state.linkSent {
        // "Check your email" state
        VStack(spacing: 16) {
          Image(systemName: "envelope.open.fill")
            .font(.system(size: 60))
            .foregroundColor(.accentColor)
            .padding(.top, 32)

          Text("Check Your Email")
            .authFont(.title)
            .fontWeight(.bold)

          Text("We've sent a verification link to:")
            .authFont(.body)
            .foregroundStyle(.secondary)

          Text(state.email)
            .authFont(.body)
            .fontWeight(.medium)
            .padding(.horizontal)

          Text("Tap the link in the email to complete reauthentication.")
            .authFont(.body)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 32)
            .padding(.top, 8)

          Button(action: state.resendLink) {
            if state.isLoading {
              ProgressView()
                .frame(height: 32)
            } else {
              Text("Resend Email")
                .authCustomFont(.body)
                .frame(height: 32)
            }
          }
          .buttonStyle(.bordered)
          .disabled(state.isLoading)
          .padding(.top, 16)
        }
      } else {
        // Loading/sending state
        VStack(spacing: 16) {
          ProgressView()
            .padding(.top, 32)
          Text("Sending verification email...")
            .authCustomFont(.body)
            .foregroundStyle(.secondary)
        }
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .navigationTitle("Verify Your Identity")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel", action: state.cancel)
      }
    }
  }
}
