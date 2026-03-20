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

import FirebaseAppleSwiftUI
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseGoogleSwiftUI
import SwiftUI
import UIKit

struct UIKitEmbeddingExample: View {
  private let authService: AuthService

  init() {
    authService = AuthService()
      .withAppleSignIn()
      .withGoogleSignIn()
      .withEmailSignIn()
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text("Embed FirebaseSwiftUI inside any UIKit container")
          .font(.title2)
          .fontWeight(.bold)

        Text(
          "This example creates a UIKit view controller, mounts a SwiftUI screen with UIHostingController, and uses AuthPickerView for the unauthenticated flow."
        )
        .foregroundStyle(.secondary)

        FirebaseAuthUIKitContainer()
          .frame(minHeight: 620)
      }
      .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
    .environment(authService)
  }
}

private struct FirebaseAuthUIKitContainer: UIViewControllerRepresentable {
  @Environment(AuthService.self) private var authService

  func makeUIViewController(context: Context) -> EmbeddedAuthViewController {
    let viewController = EmbeddedAuthViewController()
    viewController.update(authService: authService)
    return viewController
  }

  func updateUIViewController(_ uiViewController: EmbeddedAuthViewController, context: Context) {
    uiViewController.update(authService: authService)
  }
}

@MainActor
private final class EmbeddedAuthViewController: UIViewController {
  private var hostingController: UIHostingController<AnyView>?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
  }

  func update(authService: AuthService) {
    let rootView = AnyView(EmbeddedAuthView().environment(authService))

    if let hostingController {
      hostingController.rootView = rootView
      return
    }

    let hostingController = UIHostingController(rootView: rootView)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    hostingController.view.backgroundColor = .clear

    addChild(hostingController)
    view.addSubview(hostingController.view)
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    hostingController.didMove(toParent: self)

    self.hostingController = hostingController
  }
}

private struct EmbeddedAuthView: View {
  @Environment(AuthService.self) private var authService

  var body: some View {
    AuthPickerView {
      authenticatedApp
    }
    .onChange(of: authService.authenticationState) { _, newValue in
      if newValue != .authenticating {
        authService.isPresented = newValue == .unauthenticated
      }
    }
  }

  private var authenticatedApp: some View {
    VStack(spacing: 24) {
      VStack(alignment: .leading, spacing: 8) {
        Text("UIKit-hosted auth flow")
          .font(.headline)
          .fontWeight(.semibold)

        Text("This SwiftUI view is rendered by a UIKit UIViewController.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      if authService.authenticationState == .unauthenticated {
        VStack(spacing: 16) {
          Text("Not Authenticated")
            .font(.title3)
            .fontWeight(.semibold)

          Text(
            "AuthPickerView handles the sign-in UI. This UIKit-hosted screen just decides what to show before and after authentication."
          )
          .multilineTextAlignment(.center)
          .foregroundStyle(.secondary)

          Button("Authenticate") {
            authService.isPresented = true
          }
          .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
      } else {
        VStack(spacing: 20) {
          Image(systemName: "person.crop.circle.badge.checkmark")
            .font(.system(size: 56))
            .foregroundStyle(.green)

          Text(authService.currentUser?.email ?? "Signed in")
            .font(.title3)
            .fontWeight(.semibold)

          Text("Firebase Auth is now authenticated. From here, UIKit or SwiftUI can take over the rest of your app flow.")
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

          Button("Manage Account") {
            authService.isPresented = true
          }
          .buttonStyle(.bordered)

          Button("Sign Out") {
            Task {
              try? await authService.signOut()
            }
          }
          .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
      }
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(Color(UIColor.secondarySystemGroupedBackground))
    )
  }

}
