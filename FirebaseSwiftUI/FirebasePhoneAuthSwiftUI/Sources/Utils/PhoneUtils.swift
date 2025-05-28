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

class PhoneUtils {
  static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
    guard phoneNumber.first == "+" else {
      return false
    }

    let digits = phoneNumber.dropFirst()
    guard !digits.isEmpty else {
      return false
    }

    guard digits.allSatisfy({ $0.isNumber }) else {
      return false
    }

    let minLength = 7
    let maxLength = 15
    guard digits.count >= minLength && digits.count <= maxLength else {
      return false
    }

    return true
  }
}
