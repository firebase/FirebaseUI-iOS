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

  public init(displayMode: DisplayMode = .full) {
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
  public var body: some View {
    Group {
      if let tosURL = authService.configuration.tosUrl,
         let privacyURL = authService.configuration.privacyPolicyUrl {
        Text(attributedMessage(tosURL: tosURL, privacyURL: privacyURL))
          .multilineTextAlignment(displayMode == .full ? .leading : .trailing)
          .font(.footnote)
          .foregroundColor(.primary)
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
