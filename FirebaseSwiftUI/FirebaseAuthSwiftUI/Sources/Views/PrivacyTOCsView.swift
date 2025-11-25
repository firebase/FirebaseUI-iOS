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
//  PrivacyTOCsView.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 12/05/2025.
//
import FirebaseCore
import SwiftUI

@MainActor
struct PrivacyTOCsView {
  @Environment(AuthService.self) private var authService
  enum DisplayMode {
    case full, footer
  }

  let displayMode: DisplayMode

  init(displayMode: DisplayMode = .full) {
    self.displayMode = displayMode
  }

  private func attributedMessage(tosURL: URL, privacyURL: URL) -> AttributedString {
    let tosText = authService.string.termsOfServiceLabel
    let privacyText = authService.string.privacyPolicyLabel

    let format: String = displayMode == .full
      ? authService.string.termsOfServiceMessage
      : "%@    %@"

    let fullText = String(format: format, tosText, privacyText)

    var attributed = AttributedString(fullText)

    if let tosRange = attributed.range(of: tosText) {
      attributed[tosRange].link = tosURL
      attributed[tosRange].foregroundColor = .blue
    }

    if let privacyRange = attributed.range(of: privacyText) {
      attributed[privacyRange].link = privacyURL
      attributed[privacyRange].foregroundColor = .blue
    }

    return attributed
  }
}

extension PrivacyTOCsView: View {
  var body: some View {
    Group {
      if let tosURL = authService.configuration.tosUrl,
         let privacyURL = authService.configuration.privacyPolicyUrl {
        Text(attributedMessage(tosURL: tosURL, privacyURL: privacyURL))
          .multilineTextAlignment(displayMode == .full ? .center : .trailing)
          .padding()
      } else {
        EmptyView()
      }
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  let configuration = AuthConfiguration(
    tosUrl: URL(string: "https://example.com/tos"),
    privacyPolicyUrl: URL(string: "https://example.com/privacy")
  )
  let authService = AuthService(configuration: configuration)
  return PrivacyTOCsView(displayMode: .footer)
    .environment(authService)
}
