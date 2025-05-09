import CommonCrypto
import FirebaseCore
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
}

public extension FirebaseOptions {
  static func dummyConfigurationForPreview() {
    guard FirebaseApp.app() == nil else { return }

    let options = FirebaseOptions(
      googleAppID: "1:123:ios:123abc456def7890",
      gcmSenderID: "dummy"
    )
    options.apiKey = "dummy"
    options.projectID = "dummy-project-id"
    options.bundleID = Bundle.main.bundleIdentifier ?? "com.example.dummy"
    options.clientID = "dummy-abc.apps.googleusercontent.com"

    FirebaseApp.configure(options: options)
  }
}
