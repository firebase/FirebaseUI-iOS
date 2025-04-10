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
