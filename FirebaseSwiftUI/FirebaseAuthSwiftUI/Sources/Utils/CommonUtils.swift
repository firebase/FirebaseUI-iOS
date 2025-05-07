import CommonCrypto
import Foundation
import Security

public class CommonUtils {
  static let emailRegex = ".+@([a-zA-Z0-9\\-]+\\.)+[a-zA-Z0-9]{2,63}"

  public static func isValidEmail(_ email: String) -> Bool {
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
  }

  public static func randomNonce(length: Int = 32) -> String {
    let characterSet = "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
      var randoms = [UInt8](repeating: 0, count: 16)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
      if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce: OSStatus \(errorCode)")
      }

      for random in randoms {
        if remainingLength == 0 {
          break
        }

        if random < characterSet.count {
          let index = characterSet.index(characterSet.startIndex, offsetBy: Int(random))
          result.append(characterSet[index])
          remainingLength -= 1
        }
      }
    }

    return result
  }

  public static func sha256Hash(of input: String) -> String {
    guard let data = input.data(using: .utf8) else { return "" }
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return hash.map { String(format: "%02x", $0) }.joined()
  }

  public static func getQueryParamValue(from urlString: String, paramName: String) -> String? {
    guard let urlComponents = URLComponents(string: urlString) else {
      return nil
    }

    return urlComponents.queryItems?.first(where: { $0.name == paramName })?.value
  }

  public static func getAnonymousUserIdFromUrl(from urlString: String) -> String? {
    getQueryParamValue(from: urlString, paramName: "continueUrl")
      .flatMap { getQueryParamValue(from: $0, paramName: "ui_auid") }
  }
}
