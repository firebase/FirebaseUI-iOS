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

@testable import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftUI
import Testing

/// Renders `view` in a window so its body and environment are evaluated, and keeps it on screen
/// until the returned window is released.
@MainActor
private func host(_ view: some View) -> UIWindow {
  let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
  window.rootViewController = UIHostingController(rootView: view)
  window.makeKeyAndVisible()
  window.layoutIfNeeded()
  return window
}

/// Lets SwiftUI apply pending state changes and re-render.
@MainActor
private func settle() {
  RunLoop.main.run(until: Date().addingTimeInterval(0.1))
}

@MainActor
private final class Recorder<Value> {
  var value: Value?

  /// Stores `value` while content is drawn, standing in for the app's content.
  func capture(_ value: Value) -> some View {
    self.value = value
    return EmptyView()
  }
}

@Suite("Reauth screens")
@MainActor
struct ReauthScreenTests {
  init() {
    FirebaseOptions.dummyConfigurationForPreview()
  }

  @Test("Password screen is valid once a password is entered")
  func passwordValidity() {
    let state = Recorder<EmailReauthContentState>()
    let window = host(
      EmailReauthScreen(email: "test@example.com", coordinator: ReauthenticationCoordinator()) {
        state.capture($0)
      }
      .environment(AuthService())
    )
    defer { window.isHidden = true }

    #expect(state.value?.email == "test@example.com")
    #expect(state.value?.isValid == false)
    #expect(state.value?.isLoading == false)
    #expect(state.value?.errorMessage == nil)

    state.value?.password.wrappedValue = "secret"
    settle()

    #expect(state.value?.isValid == true)
  }

  @Test("Phone screen asks for a code only after one is sent, and needs 6 characters")
  func phoneValidity() {
    let state = Recorder<PhoneReauthContentState>()
    let window = host(
      PhoneReauthScreen(phoneNumber: "+15555550100", coordinator: ReauthenticationCoordinator()) {
        state.capture($0)
      }
      .environment(AuthService())
    )
    defer { window.isHidden = true }

    #expect(state.value?.phoneNumber == "+15555550100")
    #expect(state.value?.codeSent == false)
    #expect(state.value?.isValid == false)

    state.value?.verificationCode.wrappedValue = "12345"
    settle()
    #expect(state.value?.isValid == false)

    state.value?.verificationCode.wrappedValue = "123456"
    settle()
    #expect(state.value?.isValid == true)
  }

  @Test("Cancel ends the pending reauthentication request")
  func cancelEndsRequest() async {
    let coordinator = ReauthenticationCoordinator()
    let state = Recorder<EmailReauthContentState>()
    let window = host(
      EmailReauthScreen(email: "test@example.com", coordinator: coordinator) {
        state.capture($0)
      }
      .environment(AuthService())
    )
    defer { window.isHidden = true }

    let request = Task {
      try await coordinator
        .requestReauth(context: .email(EmailReauthContext(email: "test@example.com")))
    }
    await Task.yield()
    #expect(coordinator.showingEmailPasswordPrompt)

    state.value?.cancel()

    await #expect(throws: AuthServiceError.self) { try await request.value }
    #expect(!coordinator.showingEmailPasswordPrompt)
  }
}

@Suite("Reauth content slot")
@MainActor
struct ReauthContentSlotTests {
  private let prompt = ReauthPrompt.emailLink(EmailLinkReauthContentState(
    resendLink: {},
    cancel: {},
    email: "test@example.com",
    linkSent: true,
    isLoading: false,
    errorMessage: nil
  ))

  @Test("No reauth content is set by default")
  func defaultIsNil() {
    #expect(EnvironmentValues().reauthContent == nil)
  }

  @Test("Prompts inside reauthContent are drawn by the app's content")
  func usesAppContent() {
    let received = Recorder<ReauthPrompt>()
    let window = host(
      ReauthPromptContent(prompt: prompt)
        .reauthContent { prompt in
          received.capture(prompt)
        }
    )
    defer { window.isHidden = true }

    guard case let .emailLink(state) = received.value else {
      Issue.record("Expected the email link prompt, got \(String(describing: received.value))")
      return
    }
    #expect(state.email == "test@example.com")
    #expect(state.linkSent)
  }

  @Test("The nearest reauthContent wins")
  func innermostContentWins() {
    let outer = Recorder<ReauthPrompt>()
    let inner = Recorder<ReauthPrompt>()
    let window = host(
      ReauthPromptContent(prompt: prompt)
        .reauthContent { prompt in
          inner.capture(prompt)
        }
        .reauthContent { prompt in
          outer.capture(prompt)
        }
    )
    defer { window.isHidden = true }

    #expect(inner.value != nil)
    #expect(outer.value == nil)
  }
}
