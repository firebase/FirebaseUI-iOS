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

/// A reauthentication prompt and its state, passed to the content given to
/// ``SwiftUICore/View/reauthContent(_:)``.
public enum ReauthPrompt {
  /// The user signed in with email and password.
  case password(EmailReauthContentState)
  /// The user signed in with a phone number.
  case phone(PhoneReauthContentState)
  /// The user signed in with an email link.
  case emailLink(EmailLinkReauthContentState)
}

/// The stock content for a reauthentication prompt, for the cases your
/// ``SwiftUICore/View/reauthContent(_:)`` content does not replace.
@MainActor
public struct DefaultReauthContent: View {
  public init(prompt: ReauthPrompt) {
    self.prompt = prompt
  }

  private let prompt: ReauthPrompt

  public var body: some View {
    switch prompt {
    case let .password(state):
      DefaultEmailReauthContent(state: state)
    case let .phone(state):
      DefaultPhoneReauthContent(state: state)
    case let .emailLink(state):
      DefaultEmailLinkReauthContent(state: state)
    }
  }
}

private struct ReauthContentKey: @preconcurrency EnvironmentKey {
  @MainActor static let defaultValue: (@MainActor (ReauthPrompt) -> AnyView)? = nil
}

extension EnvironmentValues {
  var reauthContent: (@MainActor (ReauthPrompt) -> AnyView)? {
    get { self[ReauthContentKey.self] }
    set { self[ReauthContentKey.self] = newValue }
  }
}

/// Draws the content of a reauthentication prompt, using the app's content when one was given.
struct ReauthPromptContent: View {
  @Environment(\.reauthContent) private var reauthContent
  let prompt: ReauthPrompt

  var body: some View {
    if let reauthContent {
      reauthContent(prompt)
    } else {
      DefaultReauthContent(prompt: prompt)
    }
  }
}

public extension View {
  /// Replaces the content of the password, phone, and email link reauthentication prompts shown
  /// inside this view.
  ///
  /// Reauthentication is asked for when a sensitive action, such as deleting the account or
  /// changing the password, needs a recent sign-in. The prompts stay sheets that verify the
  /// user, resolve a second factor, and report errors. Your content only draws the UI from the
  /// state in the ``ReauthPrompt`` it receives. Return ``DefaultReauthContent`` for prompts you
  /// do not replace.
  ///
  /// Example:
  /// ```swift
  /// AuthPickerView { authenticatedApp }
  ///   .reauthContent { prompt in
  ///     switch prompt {
  ///     case let .password(state):
  ///       SecureField("Password", text: state.password)
  ///       Button("Confirm", action: state.verify)
  ///         .disabled(!state.isValid || state.isLoading)
  ///       Button("Cancel", action: state.cancel)
  ///     default:
  ///       DefaultReauthContent(prompt: prompt)
  ///     }
  ///   }
  /// ```
  func reauthContent<Content: View>(@ViewBuilder _ content: @escaping @MainActor (ReauthPrompt)
    -> Content) -> some View {
    environment(\.reauthContent) { AnyView(content($0)) }
  }
}
