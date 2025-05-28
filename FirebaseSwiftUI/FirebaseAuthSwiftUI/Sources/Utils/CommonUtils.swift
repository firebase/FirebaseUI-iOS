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

  public static func getQueryParamValue(from urlString: String, paramName: String) -> String? {
    guard let urlComponents = URLComponents(string: urlString) else {
      return nil
    }

    return urlComponents.queryItems?.first(where: { $0.name == paramName })?.value
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
