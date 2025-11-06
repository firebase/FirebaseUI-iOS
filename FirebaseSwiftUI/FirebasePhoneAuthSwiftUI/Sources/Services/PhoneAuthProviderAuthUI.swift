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

import FirebaseAuthSwiftUI
import SwiftUI

/// Simple provider marker for phone authentication
public class PhoneProviderSwift: AuthProviderSwift {
  public init() {}
}

public class PhoneAuthProviderAuthUI: AuthProviderUI {
  private let typedProvider: PhoneProviderSwift
  public var provider: AuthProviderSwift { typedProvider }
  public let id: String = "phone"

  public init() {
    typedProvider = PhoneProviderSwift()
  }

  @MainActor public func authButton() -> AnyView {
    AnyView(PhoneAuthButtonView())
  }
}
