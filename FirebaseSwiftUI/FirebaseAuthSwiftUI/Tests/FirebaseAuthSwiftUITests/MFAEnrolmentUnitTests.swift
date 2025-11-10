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

//
//  MFAEnrollmentUnitTests.swift
//  FirebaseAuthSwiftUITests
//
//  Unit tests for MFA enrollment data structures
//

import FirebaseAuth
import FirebaseAuthSwiftUI
import Foundation
import Testing

// MARK: - TOTPEnrollmentInfo Tests

@Suite("TOTPEnrollmentInfo Tests")
struct TOTPEnrollmentInfoTests {
  @Test("Initialization with shared secret key")
  func initializationWithSharedSecretKey() {
    let validSecrets = [
      "JBSWY3DPEHPK3PXP",
      "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ",
      "MFRGG43FMZQW4ZY=",
    ]

    for secret in validSecrets {
      let totpInfo = TOTPEnrollmentInfo(sharedSecretKey: secret)
      #expect(totpInfo.sharedSecretKey == secret)
      #expect(totpInfo.verificationStatus == .pending)
      #expect(totpInfo.qrCodeURL == nil)
      #expect(totpInfo.accountName == nil)
      #expect(totpInfo.issuer == nil)
    }
  }

  @Test("Initialization with all parameters")
  func initializationWithAllParameters() throws {
    let totpInfo = TOTPEnrollmentInfo(
      sharedSecretKey: "JBSWY3DPEHPK3PXP",
      qrCodeURL: URL(
        string: "otpauth://totp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example"
      ),
      accountName: "alice@example.com",
      issuer: "Example",
      verificationStatus: .verified
    )

    #expect(totpInfo.sharedSecretKey == "JBSWY3DPEHPK3PXP")
    #expect(totpInfo.accountName == "alice@example.com")
    #expect(totpInfo.issuer == "Example")
    #expect(totpInfo.verificationStatus == .verified)

    let qrURL = try #require(totpInfo.qrCodeURL)
    #expect(qrURL.scheme == "otpauth")
    #expect(qrURL.host == "totp")
    #expect(qrURL.query?.contains("secret=JBSWY3DPEHPK3PXP") == true)
    #expect(qrURL.query?.contains("issuer=Example") == true)
  }

  @Test("Verification status transitions")
  func verificationStatusTransitions() {
    // Default status is pending
    var totpInfo = TOTPEnrollmentInfo(sharedSecretKey: "JBSWY3DPEHPK3PXP")
    #expect(totpInfo.verificationStatus == .pending)

    // Verified status
    totpInfo = TOTPEnrollmentInfo(
      sharedSecretKey: "JBSWY3DPEHPK3PXP",
      verificationStatus: .verified
    )
    #expect(totpInfo.verificationStatus == .verified)

    // Failed status
    totpInfo = TOTPEnrollmentInfo(
      sharedSecretKey: "JBSWY3DPEHPK3PXP",
      verificationStatus: .failed
    )
    #expect(totpInfo.verificationStatus == .failed)
  }
}
