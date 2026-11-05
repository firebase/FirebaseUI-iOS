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
import Testing

private typealias Challenge = MFAResolutionContentState.Challenge

private var phone: MFAHint {
  .phone(displayName: "Work", uid: "phone-1", phoneNumber: "+15551234567")
}

private var totp: MFAHint {
  .totp(displayName: "App", uid: "totp-1")
}

@Suite("MFAResolutionScreen Tests")
struct MFAResolutionScreenTests {
  @Test("Selecting a hint clears the codes and any sent code")
  func selectHintResets() {
    var challenge = Challenge(
      selectedHintIndex: 0,
      verificationCode: "123456",
      totpCode: "654321",
      verificationId: "vid"
    )
    challenge.selectHint(1)
    #expect(challenge == Challenge(selectedHintIndex: 1))
  }

  @Test("Reselecting the current hint also resets it")
  func reselectHintResets() {
    var challenge = Challenge(selectedHintIndex: 0, verificationCode: "1", verificationId: "vid")
    challenge.selectHint(0)
    #expect(challenge == Challenge(selectedHintIndex: 0))
    #expect(!challenge.isCodeSent)
  }

  @Test("A code sent for the selected hint is kept")
  func acceptCodeForSelectedHint() {
    var challenge = Challenge(selectedHintIndex: 1)
    challenge.acceptCode(verificationId: "vid", sentForHint: 1)
    #expect(challenge.verificationId == "vid")
  }

  @Test("A code sent for a hint the user left is dropped")
  func dropCodeForStaleHint() {
    var challenge = Challenge(selectedHintIndex: 0)
    challenge.selectHint(1)
    challenge.acceptCode(verificationId: "vid", sentForHint: 0)
    #expect(challenge.verificationId == nil)
  }

  @Test("A phone hint needs a sent code and a typed code")
  func phoneValidity() {
    let hints = [phone]
    #expect(!Challenge(verificationCode: "123456").isValid(hints: hints))
    #expect(!Challenge(verificationId: "vid").isValid(hints: hints))
    #expect(Challenge(verificationCode: "123456", verificationId: "vid").isValid(hints: hints))
    #expect(!Challenge(totpCode: "123456", verificationId: "vid").isValid(hints: hints))
  }

  @Test("A TOTP hint needs only its code")
  func totpValidity() {
    let hints = [phone, totp]
    #expect(Challenge(selectedHintIndex: 1, totpCode: "123456").isValid(hints: hints))
    #expect(!Challenge(selectedHintIndex: 1, verificationCode: "123456").isValid(hints: hints))
  }

  @Test("An out-of-range hint is never valid")
  func outOfRangeHint() {
    let challenge = Challenge(selectedHintIndex: 3, totpCode: "1", verificationId: "vid")
    #expect(!challenge.isValid(hints: [phone]))
    #expect(!challenge.canSendCode(hints: [phone], isLoading: false))
    #expect(challenge.resolveRequest(hints: [phone], isLoading: false) == nil)
  }

  @Test("Codes are sent only for a phone hint and when idle")
  func sendCodeGuard() {
    #expect(Challenge().canSendCode(hints: [phone], isLoading: false))
    #expect(!Challenge().canSendCode(hints: [phone], isLoading: true))
    #expect(!Challenge().canSendCode(hints: [totp], isLoading: false))
  }

  @Test("Resolve captures the selected hint's code, index and verification ID")
  func resolveRequest() {
    let hints = [phone, totp]
    let sms = Challenge(verificationCode: "111111", totpCode: "222222", verificationId: "vid")
    #expect(sms.resolveRequest(hints: hints, isLoading: false)
      == .init(code: "111111", hintIndex: 0, verificationId: "vid"))
    let app = Challenge(selectedHintIndex: 1, verificationCode: "111111", totpCode: "222222")
    #expect(app.resolveRequest(hints: hints, isLoading: false)
      == .init(code: "222222", hintIndex: 1, verificationId: nil))
  }

  @Test("Resolve does nothing while loading or invalid")
  func resolveGuard() {
    let valid = Challenge(verificationCode: "111111", verificationId: "vid")
    #expect(valid.resolveRequest(hints: [phone], isLoading: true) == nil)
    #expect(Challenge(verificationCode: "111111").resolveRequest(hints: [phone], isLoading: false)
      == nil)
  }
}
