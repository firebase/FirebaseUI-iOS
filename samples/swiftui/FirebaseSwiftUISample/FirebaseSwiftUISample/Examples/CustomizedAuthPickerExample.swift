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
import FirebaseAuthSwiftUI
import FirebaseAuthUIComponents
import SwiftUI

/// Demonstrates `AuthPickerView`'s full customization surface — `pickerContent`/
/// `pickerDestination`, a custom `authMethodPicker` layout (see `SpotlightMethodPicker`),
/// `AuthTextFieldStyle`, `AuthCTAButtonStyle`, and `AuthTypography` — using fixed values instead
/// of an app-wide theme system, so each hook is easy to see in isolation. Swap the constants
/// below for values read from your own theme if you want them switchable at runtime.
struct CustomizedAuthPickerExample: View {
  @Environment(AuthService.self) private var authService

  private let tint = Color.orange
  private let background = Color(red: 42 / 255, green: 1 / 255, blue: 52 / 255)
  private let container = Color(.secondarySystemBackground)
  private let secondary = Color.gray
  private let error = Color.red

  var body: some View {
    AuthPickerView {
      authenticatedApp
    }
    .pickerContent {
      AuthPickerContentView { providers, onProviderSelected in
        SpotlightMethodPicker(providers: providers, onProviderSelected: onProviderSelected)
      }
      .tint(tint)
      .background(background)
    }
    .pickerDestination { screen in
      AuthPickerDestinationView(screen: screen)
        .tint(tint)
        .background(background)
    }
    .authTextFieldStyle(
      AuthTextFieldStyle(
        tint: tint,
        containerColor: container,
        secondaryColor: secondary,
        errorColor: error
      )
    )
    .authTypography(
      AuthTypography(fontFamily: "AmericanTypewriter")
    )
    .authCTAButtonStyle(
      AuthCTAButtonStyle(backgroundColor: tint, contentColor: .white, shape: .capsule)
    )
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
  }
}

#Preview {
  CustomizedAuthPickerExample()
    .environment(AuthService().withEmailSignIn())
}
