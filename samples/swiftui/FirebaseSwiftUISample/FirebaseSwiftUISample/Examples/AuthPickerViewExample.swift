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

import SwiftUI
import FirebaseAuthSwiftUI
import FirebaseAuth

struct AuthPickerViewExample: View {
  @Environment(AuthService.self) private var authService
  
  var body: some View {
    AuthPickerView {
      authenticatedApp
    }
  }
  
  var authenticatedApp: some View {
    NavigationStack {
      VStack {
        if authService.authenticationState == .unauthenticated {
          Text("Not Authenticated")
          Button {
            authService.isPresented = true
          } label: {
            Text("Authenticate")
          }
          .buttonStyle(.bordered)
        } else {
          Text("Authenticated - \(authService.currentUser?.email ?? "")")
          Button {
            authService.isPresented = true // Reopen the sheet
          } label: {
            Text("Manage Account")
          }
          .buttonStyle(.bordered)
          Button {
            Task {
              try? await authService.signOut()
            }
          } label: {
            Text("Sign Out")
          }
          .buttonStyle(.borderedProminent)
        }
      }
    }
    .onChange(of: authService.authenticationState) { _, newValue in
      if newValue != .authenticating {
        authService.isPresented = newValue == .unauthenticated
      }
    }
  }
}
