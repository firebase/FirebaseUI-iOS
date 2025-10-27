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

import SwiftUI
import FirebaseAuth

enum AuthProvider: CaseIterable {
    case google
    case facebook
    case twitter
    case github
    case email
    case phone
    case anonymous
    case microsoft
    case yahoo
    case apple
    
    var id: String {
        switch self {
        case .google: return GoogleAuthProvider.id
        case .facebook: return FacebookAuthProvider.id
        case .twitter: return TwitterAuthProvider.id
        case .github: return GitHubAuthProvider.id
        case .email: return EmailAuthProvider.id
        case .phone: return PhoneAuthProvider.id
        case .anonymous: return "anonymous"
        case .microsoft: return "microsoft.com"
        case .yahoo: return "yahoo.com"
        case .apple: return "apple.com"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .google:
            return "Sign in with Google"
        case .facebook:
            return "Sign in with Facebook"
        case .twitter:
            return "Sign in with Twitter"
        case .github:
            return "Sign in with GitHub"
        case .email:
            return "Sign in with Email"
        case .phone:
            return "Sign in with Phone"
        case .anonymous:
            return "Sign in Anonymously"
        case .microsoft:
            return "Sign in with Microsoft"
        case .yahoo:
            return "Sign in with Yahoo"
        case .apple:
            return "Sign in with Apple"
        }
    }
    
    var isSocialProvider: Bool {
        switch self {
        case .google, .facebook, .twitter, .github:
            return true
        default:
            return false
        }
    }
    
    static func from(id: String) -> AuthProvider? {
        Self.allCases.first { $0.id == id }
    }
    
    var providerStyle: ProviderStyle {
        switch self {
        case .google:
            return ProviderStyle(
                icon: .fuiIcGoogleg,
                backgroundColor: Color(hex: 0xFFFFFF),
                contentColor: Color(hex: 0x757575)
            )
        case .facebook:
            return ProviderStyle(
                icon: .fuiIcFacebook,
                backgroundColor: Color(hex: 0x3B5998),
                contentColor: Color(hex: 0xFFFFFF)
            )
        case .twitter:
            return ProviderStyle(
                icon: .fuiIcTwitterBird,
                backgroundColor: Color(hex: 0x5BAAF4),
                contentColor: Color(hex: 0xFFFFFF)
            )
        case .github:
            return ProviderStyle(
                icon: .fuiIcGithub,
                backgroundColor: Color(hex: 0x24292E),
                contentColor: Color(hex: 0xFFFFFF)
            )
        case .email:
            return ProviderStyle(
                icon: .fuiIcMail,
                backgroundColor: Color(hex: 0xD0021B),
                contentColor: Color(hex: 0xFFFFFF)
            )
        case .phone:
            return ProviderStyle(
                icon: .fuiIcPhone,
                backgroundColor: Color(hex: 0x43C5A5),
                contentColor: Color(hex: 0xFFFFFF)
            )
        case .anonymous:
            return ProviderStyle(
                icon: .fuiIcAnonymous,
                backgroundColor: Color(hex: 0xF4B400),
                contentColor: Color(hex: 0xFFFFFF)
            )
        case .microsoft:
            return ProviderStyle(
                icon: .fuiIcMicrosoft,
                backgroundColor: Color(hex: 0x2F2F2F),
                contentColor: Color(hex: 0xFFFFFF)
            )
        case .yahoo:
            return ProviderStyle(
                icon: .fuiIcYahoo,
                backgroundColor: Color(hex: 0x720E9E),
                contentColor: Color(hex: 0xFFFFFF)
            )
        case .apple:
            return ProviderStyle(
                icon: .fuiIcApple,
                backgroundColor: Color(hex: 0x000000),
                contentColor: Color(hex: 0xFFFFFF)
            )
        }
    }
}
