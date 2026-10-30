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

// The Professional theme's own layout: flat, left-aligned pages with labelled fields and grouped
// rows, instead of the shared layout the Figma themes use. It has no Figma frame; the values
// match the "Professional sign-in layout" mockups and ``DemoTheme/professional``.

/// Professional colours, each with a light and a dark variant.
enum ProPalette {
  static let background = Color(demoLight: 0xF5F6F8, dark: 0x0F1115)
  static let surface = Color(demoLight: 0xFFFFFF, dark: 0x181B20)
  static let field = Color(demoLight: 0xFFFFFF, dark: 0x0F1115)
  static let text = Color(demoLight: 0x111418, dark: 0xF2F4F7)
  static let muted = Color(demoLight: 0x5B6470, dark: 0x9AA3AE)
  static let placeholder = Color(demoLight: 0x6B7480, dark: 0x7D8693)
  static let border = Color(demoLight: 0xC9CFD6, dark: 0x3A414A)
  static let hairline = Color(demoLight: 0xE3E6EA, dark: 0x2A2F36)
  /// Links and text-only actions.
  static let accent = Color(demoLight: 0x1F5EFF, dark: 0x4C7DFF)
  /// Filled buttons: darker than ``accent`` in dark mode so white labels keep 4.5:1 contrast.
  static let accentFill = Color(demoLight: 0x1F5EFF, dark: 0x2F62F0)
  static let accentSoft = Color(demoLight: 0xEEF2FF, dark: 0x1C2540)
  static let accentSoftText = Color(demoLight: 0x1F5EFF, dark: 0x9DB5FF)
  static let tile = Color(demoLight: 0xEEF0F3, dark: 0x22262D)
  static let danger = Color(demoLight: 0xB42318, dark: 0xF97066)
  static let chevron = Color(demoLight: 0x9AA3AE, dark: 0x5B6470)
}

/// The scaffold every Professional screen shares: a scrolling, left-aligned column with a header,
/// the screen's content and an optional footer. The footer sits at the bottom when the content is
/// short, and scrolls with it otherwise, so the keyboard never pushes it over a button.
struct ProPage<Header: View, Content: View, Footer: View>: View {
  /// `showsThemeMenu` is off for screens in their own sheet, such as reauthentication.
  init(showsThemeMenu: Bool = true,
       @ViewBuilder header: () -> Header,
       @ViewBuilder content: () -> Content,
       @ViewBuilder footer: () -> Footer = { EmptyView() }) {
    self.showsThemeMenu = showsThemeMenu
    self.header = header()
    self.content = content()
    self.footer = footer()
  }

  private let showsThemeMenu: Bool
  private let header: Header
  private let content: Content
  private let footer: Footer

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          header
          content
            .padding(.top, 28)
          Spacer(minLength: 32)
          footer
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .demoContentWidth()
        .padding(.top, 8)
        .padding(.bottom, 16)
        .frame(minHeight: proxy.size.height, alignment: .top)
      }
      .scrollBounceBehavior(.basedOnSize)
    }
    .foregroundStyle(ProPalette.text)
    .background(ProPalette.background.ignoresSafeArea())
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if showsThemeMenu {
        ToolbarItem(placement: .topBarLeading) {
          DemoThemeMenu()
        }
      }
    }
  }
}

/// A title and a one-line explanation, under an optional icon tile.
struct ProHeader: View {
  var symbol: String?
  let title: String
  var subtitle: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if let symbol {
        ProIconTile(symbol: symbol, size: 44)
          .padding(.bottom, 20)
      }
      Text(title)
        .font(.system(size: 26, weight: .semibold))
        .tracking(-0.3)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("title")
      if let subtitle {
        Text(subtitle)
          .font(.system(size: 15))
          .foregroundStyle(ProPalette.muted)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.top, 6)
      }
    }
  }
}

/// An SF Symbol on a soft accent square.
struct ProIconTile: View {
  let symbol: String
  var size: CGFloat = 36
  var fill: Color = ProPalette.accentSoft
  var tint: Color = ProPalette.accentSoftText

  var body: some View {
    Image(systemName: symbol)
      .font(.system(size: size * 0.45, weight: .medium))
      .foregroundStyle(tint)
      .frame(width: size, height: size)
      .background(fill, in: RoundedRectangle(cornerRadius: size * 0.28))
      .accessibilityHidden(true)
  }
}

/// A text field with its label above it. `accessory` sits on the label's row, such as a
/// "Forgot password?" link.
struct ProField<Accessory: View>: View {
  let label: String
  let placeholder: String
  @Binding var text: String
  var isSecure = false
  var keyboard: UIKeyboardType = .default
  var contentType: UITextContentType?
  var identifier: String
  @ViewBuilder var accessory: () -> Accessory

  @State private var isRevealed = false

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(alignment: .firstTextBaseline) {
        Text(label)
          .font(.system(size: 14, weight: .medium))
        Spacer(minLength: 8)
        accessory()
      }
      HStack(spacing: 0) {
        Group {
          if isSecure, !isRevealed {
            SecureField(text: $text) { placeholderText }
          } else {
            TextField(text: $text) { placeholderText }
          }
        }
        .font(.system(size: 16))
        .keyboardType(keyboard)
        .textContentType(contentType)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier)
        if isSecure {
          Button {
            isRevealed.toggle()
          } label: {
            Image(systemName: isRevealed ? "eye.slash" : "eye")
              .foregroundStyle(ProPalette.muted)
              .frame(width: 44, height: 44)
          }
          .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
        }
      }
      .padding(.leading, 14)
      .padding(.trailing, isSecure ? 2 : 14)
      .frame(height: 48)
      .proFieldBox()
    }
  }

  private var placeholderText: Text {
    Text(placeholder).foregroundStyle(ProPalette.placeholder)
  }
}

extension ProField where Accessory == EmptyView {
  init(label: String,
       placeholder: String,
       text: Binding<String>,
       isSecure: Bool = false,
       keyboard: UIKeyboardType = .default,
       contentType: UITextContentType? = nil,
       identifier: String) {
    self.init(
      label: label,
      placeholder: placeholder,
      text: text,
      isSecure: isSecure,
      keyboard: keyboard,
      contentType: contentType,
      identifier: identifier,
      accessory: { EmptyView() }
    )
  }
}

extension View {
  /// The Professional text field's box: field fill, 1-point border, 10-point corners.
  func proFieldBox() -> some View {
    let shape = RoundedRectangle(cornerRadius: 10)
    return background(ProPalette.field, in: shape)
      .overlay { shape.strokeBorder(ProPalette.border, lineWidth: 1) }
  }
}

/// The phone number field: the library's `CountrySelector` beside a number field.
struct ProPhoneField: View {
  let phoneNumber: Binding<String>
  let country: Binding<CountryData>

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Phone number")
        .font(.system(size: 14, weight: .medium))
      HStack(spacing: 10) {
        CountrySelector(selectedCountry: country)
          .tint(ProPalette.text)
          .accessibilityIdentifier("country-selector")
        Rectangle()
          .fill(ProPalette.hairline)
          .frame(width: 1, height: 24)
        TextField(text: phoneNumber) {
          Text("555 123 4567").foregroundStyle(ProPalette.placeholder)
        }
        .font(.system(size: 16))
        .keyboardType(.phonePad)
        .textContentType(.telephoneNumber)
        .accessibilityLabel("Phone number")
        .accessibilityIdentifier("phone-number-field")
      }
      .padding(.horizontal, 14)
      .frame(height: 48)
      .proFieldBox()
    }
  }
}

/// The full-width filled button.
struct ProPrimaryButton: View {
  let title: String
  var isLoading = false
  var identifier: String
  let action: () -> Void

  @Environment(\.isEnabled) private var isEnabled

  var body: some View {
    Button(action: action) {
      ZStack {
        Text(title)
          .font(.system(size: 17, weight: .semibold))
          .opacity(isLoading ? 0 : 1)
        if isLoading {
          ProgressView().tint(.white)
        }
      }
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity, minHeight: 52)
      .background(ProPalette.accentFill, in: RoundedRectangle(cornerRadius: 10))
      .opacity(isEnabled ? 1 : 0.45)
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(identifier)
  }
}

/// A full-width outlined button, for the sign-in providers.
struct ProOutlineButton<Icon: View>: View {
  let title: String
  var identifier: String
  @ViewBuilder let icon: () -> Icon
  let action: () -> Void

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: 10)
    Button(action: action) {
      HStack(spacing: 10) {
        icon()
          .frame(width: 20, height: 20)
        Text(title)
          .font(.system(size: 15, weight: .semibold))
      }
      .foregroundStyle(ProPalette.text)
      .frame(maxWidth: .infinity, minHeight: 48)
      .background(ProPalette.surface, in: shape)
      .overlay { shape.strokeBorder(ProPalette.border, lineWidth: 1) }
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(identifier)
  }
}

/// A text-only action in the accent colour, 44 points tall.
struct ProTextButton: View {
  let title: String
  var alignment: Alignment = .center
  var identifier: String
  let action: () -> Void

  @Environment(\.isEnabled) private var isEnabled

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(ProPalette.accent)
        .opacity(isEnabled ? 1 : 0.5)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: alignment)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(identifier)
  }
}

/// "Prompt? Action", centred, with only the action tappable.
struct ProPromptLink: View {
  let prompt: String
  let action: String
  var identifier: String
  let perform: () -> Void

  var body: some View {
    HStack(spacing: 4) {
      Text(prompt)
        .foregroundStyle(ProPalette.muted)
      Button(action: perform) {
        Text(action)
          .fontWeight(.medium)
          .foregroundStyle(ProPalette.accent)
          .frame(minHeight: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityIdentifier(identifier)
    }
    .font(.system(size: 15))
    .frame(maxWidth: .infinity)
  }
}

/// A rule with a short label in the middle.
struct ProDivider: View {
  let label: String

  var body: some View {
    HStack(spacing: 12) {
      line
      Text(label)
        .font(.system(size: 13))
        .foregroundStyle(ProPalette.muted)
        .fixedSize()
      line
    }
  }

  private var line: some View {
    Rectangle().fill(ProPalette.hairline).frame(height: 1)
  }
}

/// A content slot's `errorMessage`.
struct ProErrorText: View {
  let message: String?

  var body: some View {
    if let message {
      Label {
        Text(message)
          .fixedSize(horizontal: false, vertical: true)
      } icon: {
        Image(systemName: "exclamationmark.circle")
      }
      .font(.system(size: 14))
      .foregroundStyle(ProPalette.danger)
      .accessibilityIdentifier("error-message")
    }
  }
}

/// A small uppercase label above a ``ProGroup``.
struct ProSectionLabel: View {
  let text: String

  var body: some View {
    Text(text)
      .font(.system(size: 13, weight: .medium))
      .tracking(0.3)
      .textCase(.uppercase)
      .foregroundStyle(ProPalette.muted)
      .padding(.horizontal, 4)
      .padding(.bottom, 8)
  }
}

/// Grouped rows on a bordered card, like an iOS Settings section. Separate rows with
/// ``ProRowSeparator``.
struct ProGroup<Content: View>: View {
  @ViewBuilder let content: () -> Content

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: 12)
    VStack(spacing: 0, content: content)
      .background(ProPalette.surface, in: shape)
      .clipShape(shape)
      .overlay { shape.strokeBorder(ProPalette.hairline, lineWidth: 1) }
  }
}

/// The hairline between rows, inset past a row's icon.
struct ProRowSeparator: View {
  var inset: CGFloat = 48

  var body: some View {
    Rectangle()
      .fill(ProPalette.hairline)
      .frame(height: 1)
      .padding(.leading, inset)
  }
}

/// One tappable settings row: an optional icon, a title, an optional value and a chevron.
struct ProRow: View {
  var symbol: String?
  let title: String
  var value: String?
  var valueTint: Color = ProPalette.muted
  var tint: Color = ProPalette.text
  var showsChevron = true
  var identifier: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        if let symbol {
          Image(systemName: symbol)
            .font(.system(size: 17))
            .frame(width: 20)
            .accessibilityHidden(true)
        }
        Text(title)
          .font(.system(size: 16, weight: symbol == nil ? .medium : .regular))
          .frame(maxWidth: .infinity, alignment: .leading)
        if let value {
          Text(value)
            .font(.system(size: 15))
            .foregroundStyle(valueTint)
        }
        if showsChevron {
          Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(ProPalette.chevron)
            .accessibilityHidden(true)
        }
      }
      .foregroundStyle(tint)
      .padding(.horizontal, 16)
      .frame(minHeight: 52)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(identifier)
  }
}

/// A selectable row in a ``ProGroup``: icon tile, title, description and a radio mark.
struct ProChoiceRow: View {
  let symbol: String
  let title: String
  let detail: String
  let isSelected: Bool
  var identifier: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 14) {
        ProIconTile(
          symbol: symbol,
          fill: isSelected ? ProPalette.accentSoft : ProPalette.tile,
          tint: isSelected ? ProPalette.accentSoftText : ProPalette.text
        )
        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.system(size: 16, weight: .medium))
          Text(detail)
            .font(.system(size: 14))
            .foregroundStyle(ProPalette.muted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
          .font(.system(size: 22))
          .foregroundStyle(isSelected ? ProPalette.accent : ProPalette.border)
          .accessibilityHidden(true)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .accessibilityIdentifier(identifier)
  }
}

/// The terms line for screens that create or sign in to an account, from the configured URLs.
struct ProLegalText: View {
  var prefix = "By continuing, you agree to the"

  @Environment(AuthService.self) private var authService

  var body: some View {
    let configuration = authService.configuration
    if let tos = configuration.tosUrl, let privacy = configuration.privacyPolicyUrl,
       let terms = try? AttributedString(markdown: """
       \(prefix) [Terms of Service](\(tos.absoluteString)) \
       and [Privacy Policy](\(privacy.absoluteString)).
       """) {
      Text(terms)
        .font(.system(size: 13))
        .foregroundStyle(ProPalette.muted)
        .tint(ProPalette.accent)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("terms")
    }
  }
}
