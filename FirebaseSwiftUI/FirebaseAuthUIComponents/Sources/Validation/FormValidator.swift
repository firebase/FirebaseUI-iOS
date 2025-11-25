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

import Foundation

public struct FormValidator: Identifiable {
  public let id = UUID()
  public let message: String
  public let validate: (String?) -> Bool

  public init(message: String, validate: @escaping (String?) -> Bool) {
    self.message = message
    self.validate = validate
  }

  public func isValid(input: String?) -> Bool {
    return validate(input)
  }
}

@MainActor
public struct FormValidators {
  public static let email = FormValidator(
    message: "Email must contain @ and domain",
    validate: { input in
      guard let input else { return false }
      let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
      let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
      return predicate.evaluate(with: input)
    }
  )

  public static func confirmPassword(password: @autoclosure @escaping () -> String)
    -> FormValidator {
    return FormValidator(
      message: "Passwords must match",
      validate: { input in
        guard let input else { return false }
        return input == password()
      }
    )
  }

  public static let atLeast6Characters = FormValidator(
    message: "Password must be at least 6 characters",
    validate: { input in
      guard let input else { return false }
      return input.count >= 6
    }
  )

  public static func notEmpty(label: String) -> FormValidator {
    return FormValidator(
      message: "\(label) cannot be empty",
      validate: { input in
        guard let input else { return false }
        return !input.isEmpty
      }
    )
  }

  public static let phoneNumber = FormValidator(
    message: "Phone number is not valid",
    validate: { input in
      guard let input else { return false }
      // Basic phone number validation (digits only, at least 7 characters)
      let digitsOnly = input.filter { $0.isNumber }
      return digitsOnly.count >= 7
    }
  )

  public static let verificationCode = FormValidator(
    message: "Verification code must be 6 digits",
    validate: { input in
      guard let input else { return false }
      let digitsOnly = input.filter { $0.isNumber }
      return digitsOnly.count == 6
    }
  )
}
