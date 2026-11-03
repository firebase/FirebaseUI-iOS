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

import FirebaseAuthSwiftUI
import Testing

/// Each public email state initializer must be callable with no arguments, so adding a field with
/// a default later never breaks a consumer's preview. These fail to compile if a parameter loses
/// its default.
@Suite("Email content state defaults")
@MainActor
struct EmailContentStateDefaultsTests {
  @Test("EmailAuthContentState builds with no arguments")
  func emailAuthContentState() {
    let state = EmailAuthContentState()
    #expect(state.email.wrappedValue.isEmpty)
    #expect(state.flow == .signIn)
    #expect(!state.isValid && !state.isLoading && state.errorMessage == nil)
  }

  @Test("PasswordRecoveryContentState builds with no arguments")
  func passwordRecoveryContentState() {
    let state = PasswordRecoveryContentState()
    #expect(state.email.wrappedValue.isEmpty)
    #expect(!state.didSend && state.sentEmail.isEmpty)
    #expect(!state.isValid && !state.isLoading && state.errorMessage == nil)
  }

  @Test("EmailLinkContentState builds with no arguments")
  func emailLinkContentState() {
    let state = EmailLinkContentState()
    #expect(state.email.wrappedValue.isEmpty)
    #expect(!state.didSend)
    #expect(!state.isValid && !state.isLoading && state.errorMessage == nil)
  }

  @Test("A preview passes only the fields it needs")
  func partialArguments() {
    let state = EmailAuthContentState(flow: .signUp, errorMessage: "Wrong password")
    #expect(state.flow == .signUp)
    #expect(state.errorMessage == "Wrong password")
  }
}
