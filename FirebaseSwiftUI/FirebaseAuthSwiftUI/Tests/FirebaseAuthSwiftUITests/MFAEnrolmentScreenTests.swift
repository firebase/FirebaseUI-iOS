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

private typealias Step = MFAEnrollmentContentState.Step

@Suite("MFAEnrolmentScreen Tests")
struct MFAEnrolmentScreenTests {
  @Test("Allowed factors list SMS first")
  func sortedFactorsListSMSFirst() {
    #expect(MFAEnrollmentContentState.sortedFactors([.totp, .sms]) == [.sms, .totp])
    #expect(MFAEnrollmentContentState.sortedFactors([.totp]) == [.totp])
    #expect(MFAEnrollmentContentState.sortedFactors([]).isEmpty)
  }

  @Test("SMS sessions map to the phone number and code steps")
  func smsSessionSteps() {
    #expect(Step(type: .sms, status: .initiated, isExpired: false) == .enterPhoneNumber)
    #expect(Step(type: .sms, status: .verificationSent, isExpired: false)
      == .enterVerificationCode)
    #expect(Step(type: .sms, status: .verificationPending, isExpired: false)
      == .enterVerificationCode)
  }

  @Test("TOTP sessions map to the authenticator step")
  func totpSessionSteps() {
    #expect(Step(type: .totp, status: .initiated, isExpired: false) == .setUpTOTP)
    #expect(Step(type: .totp, status: .verificationPending, isExpired: false) == .setUpTOTP)
  }

  @Test("Finished sessions go back to factor selection")
  func finishedSessionsSelectFactor() {
    let statuses: [EnrollmentSession.EnrollmentStatus] = [.completed, .failed, .expired]
    for status in statuses {
      #expect(Step(type: .sms, status: status, isExpired: false) == .selectFactor)
      #expect(Step(type: .totp, status: status, isExpired: false) == .selectFactor)
    }
  }

  @Test("Expired sessions go back to factor selection")
  func expiredSessionsSelectFactor() {
    #expect(Step(type: .sms, status: .initiated, isExpired: true) == .selectFactor)
    #expect(Step(type: .sms, status: .verificationSent, isExpired: true) == .selectFactor)
    #expect(Step(type: .totp, status: .initiated, isExpired: true) == .selectFactor)
  }

  @Test("Factor selection needs MFA enabled and an allowed factor")
  func selectFactorValidity() {
    #expect(isValid(.selectFactor))
    #expect(!isValid(.selectFactor, isMFAEnabled: false))
    #expect(!isValid(.selectFactor, allowedFactors: []))
    #expect(!isValid(.selectFactor, allowedFactors: [.sms], selectedFactorType: .totp))
  }

  @Test("Phone number step needs a number and a display name")
  func enterPhoneNumberValidity() {
    #expect(isValid(.enterPhoneNumber, phoneNumber: "5551234567", displayName: "Phone"))
    #expect(!isValid(.enterPhoneNumber, phoneNumber: "", displayName: "Phone"))
    #expect(!isValid(.enterPhoneNumber, phoneNumber: "5551234567", displayName: ""))
  }

  @Test("Code steps need their own code and a display name")
  func codeStepValidity() {
    #expect(isValid(.enterVerificationCode, verificationCode: "123456", displayName: "Phone"))
    #expect(!isValid(.enterVerificationCode, totpCode: "123456", displayName: "Phone"))
    #expect(!isValid(.enterVerificationCode, verificationCode: "123456", displayName: ""))
    #expect(isValid(.setUpTOTP, totpCode: "123456", displayName: "App"))
    #expect(!isValid(.setUpTOTP, verificationCode: "123456", displayName: "App"))
    #expect(!isValid(.setUpTOTP, totpCode: "123456", displayName: ""))
  }

  @Test("Get Started runs only from factor selection")
  func startEnrollmentGuard() {
    #expect(Step.selectFactor.canStartEnrollment(isValid: true, isLoading: false))
    #expect(!Step.selectFactor.canStartEnrollment(isValid: false, isLoading: false))
    #expect(!Step.selectFactor.canStartEnrollment(isValid: true, isLoading: true))
    for step in [Step.enterPhoneNumber, .enterVerificationCode, .setUpTOTP] {
      #expect(!step.canStartEnrollment(isValid: true, isLoading: false))
    }
  }

  @Test("Codes are sent only from the SMS steps")
  func sendCodeGuard() {
    for step in [Step.enterPhoneNumber, .enterVerificationCode] {
      #expect(step.canSendCode(phoneNumber: "5551234567", displayName: "Phone", isLoading: false))
      #expect(!step.canSendCode(phoneNumber: "", displayName: "Phone", isLoading: false))
      #expect(!step.canSendCode(phoneNumber: "5551234567", displayName: "", isLoading: false))
      #expect(!step.canSendCode(phoneNumber: "5551234567", displayName: "Phone", isLoading: true))
    }
    for step in [Step.selectFactor, .setUpTOTP] {
      #expect(!step.canSendCode(phoneNumber: "5551234567", displayName: "Phone", isLoading: false))
    }
  }

  @Test("Enrolment runs only from the code steps")
  func enrollGuard() {
    for step in [Step.enterVerificationCode, .setUpTOTP] {
      #expect(step.canEnroll(isValid: true, isLoading: false))
      #expect(!step.canEnroll(isValid: false, isLoading: false))
      #expect(!step.canEnroll(isValid: true, isLoading: true))
    }
    for step in [Step.selectFactor, .enterPhoneNumber] {
      #expect(!step.canEnroll(isValid: true, isLoading: false))
    }
  }

  private func isValid(_ step: Step,
                       isMFAEnabled: Bool = true,
                       allowedFactors: [SecondFactorType] = [.sms, .totp],
                       selectedFactorType: SecondFactorType = .sms,
                       phoneNumber: String = "",
                       verificationCode: String = "",
                       totpCode: String = "",
                       displayName: String = "") -> Bool {
    step.isValid(
      isMFAEnabled: isMFAEnabled,
      allowedFactors: allowedFactors,
      selectedFactorType: selectedFactorType,
      phoneNumber: phoneNumber,
      verificationCode: verificationCode,
      totpCode: totpCode,
      displayName: displayName
    )
  }
}
