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
@preconcurrency import FirebaseAuth
import SwiftUI

public enum SecondFactorType {
  case sms
  case totp
}

public struct TOTPEnrollmentInfo {
  public let sharedSecretKey: String
  public let qrCodeURL: URL?
  public let accountName: String?
  public let issuer: String?
  public let verificationStatus: VerificationStatus

  public enum VerificationStatus {
    case pending
    case verified
    case failed
  }

  public init(sharedSecretKey: String,
              qrCodeURL: URL? = nil,
              accountName: String? = nil,
              issuer: String? = nil,
              verificationStatus: VerificationStatus = .pending) {
    self.sharedSecretKey = sharedSecretKey
    self.qrCodeURL = qrCodeURL
    self.accountName = accountName
    self.issuer = issuer
    self.verificationStatus = verificationStatus
  }
}

public struct EnrollmentSession {
  public let id: String
  public let type: SecondFactorType
  public let session: MultiFactorSession
  public let totpInfo: TOTPEnrollmentInfo?
  public let phoneNumber: String?
  public let verificationId: String?
  public let status: EnrollmentStatus
  public let createdAt: Date
  public let expiresAt: Date

  // Internal handle to finish TOTP
  let _totpSecret: AnyObject?

  public enum EnrollmentStatus {
    case initiated
    case verificationSent
    case verificationPending
    case completed
    case failed
    case expired
  }

  public init(id: String = UUID().uuidString,
              type: SecondFactorType,
              session: MultiFactorSession,
              totpInfo: TOTPEnrollmentInfo? = nil,
              phoneNumber: String? = nil,
              verificationId: String? = nil,
              status: EnrollmentStatus = .initiated,
              createdAt: Date = Date(),
              expiresAt: Date = Date().addingTimeInterval(600), // 10 minutes default
              _totpSecret: AnyObject? = nil) {
    self.id = id
    self.type = type
    self.session = session
    self.totpInfo = totpInfo
    self.phoneNumber = phoneNumber
    self.verificationId = verificationId
    self.status = status
    self.createdAt = createdAt
    self.expiresAt = expiresAt
    self._totpSecret = _totpSecret
  }

  public var isExpired: Bool {
    return Date() > expiresAt
  }

  public var canProceed: Bool {
    return !isExpired &&
      (status == .initiated || status == .verificationSent || status == .verificationPending)
  }
}

public enum MFAHint: Hashable {
  case phone(displayName: String?, uid: String, phoneNumber: String?)
  case totp(displayName: String?, uid: String)
}

public struct MFARequired: Hashable {
  public let hints: [MFAHint]

  public init(hints: [MFAHint]) {
    self.hints = hints
  }
}
