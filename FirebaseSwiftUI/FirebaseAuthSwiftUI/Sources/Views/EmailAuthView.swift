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

//
//  EmailPasswordView.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 20/03/2025.
//
import FirebaseCore
import SwiftUI

@MainActor
public struct EmailAuthView {
  public init() {}
}

extension EmailAuthView: View {
  public var body: some View {
    EmailAuthScreen { DefaultEmailAuthContent(state: $0) }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return EmailAuthView()
    .environment(AuthService())
}
