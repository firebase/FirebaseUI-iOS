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

/// The layout every demo screen shares, from the Figma "sign up" frame: a title, a form card and
/// an optional footer, over the theme's background art. Accessibility identifiers use the Figma
/// layer names.
struct DemoPage<Card: View, Footer: View>: View {
  /// `showsThemeMenu` is off for screens in their own sheet, such as reauthentication.
  init(title: String?,
       showsThemeMenu: Bool = true,
       @ViewBuilder card: @escaping () -> Card,
       @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }) {
    self.title = title
    self.showsThemeMenu = showsThemeMenu
    self.card = card
    self.footer = footer
  }

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  private let title: String?
  private let showsThemeMenu: Bool
  private let card: () -> Card
  private let footer: () -> Footer

  var body: some View {
    let theme = themeID.theme
    // The background is its own layer, so it fills the sheet whatever size the scroll view takes.
    ZStack {
      DemoThemeBackground(theme: theme)
      ScrollView {
        VStack(spacing: 0) {
          if theme.id == .spark {
            SparkHeadline()
              // "headline" ends at y 135 and "inputs" starts at y 200.
              .padding(.bottom, title == nil ? 65 : 24)
          }
          VStack(alignment: .leading, spacing: theme.titleSpacing) {
            if let title {
              Text(title)
                .font(theme.title.font(relativeTo: .title))
                .foregroundStyle(theme.title.color)
                // Long titles wrap before the 83-point mascot and its 8.6-point inset.
                .padding(.trailing, theme.id == .doggo ? 92 : 0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("title")
            }
            DemoCard(theme: theme, content: card)
          }
          .overlay(alignment: .topTrailing) {
            if theme.id == .doggo, title != nil {
              // "doggo" ends 8.6 points inside the form's trailing edge (x 372.4 against 381) and
              // starts 10.7 points above the title (y 163.3 against 174).
              Image("FullCustomization/doggo-mascot")
                .offset(x: -8.6, y: -10.7)
                .accessibilityHidden(true)
                .accessibilityIdentifier("doggo")
            }
          }
          .demoContentWidth()
          footer()
            // With the switch row's 12-point inset, its text sits 24 points below the form.
            .padding(.top, 12)
        }
        // Full width, so the whole sheet scrolls while the form stays centred.
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 24)
      }
      .scrollBounceBehavior(.basedOnSize)
    }
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

/// Figma "headline" (20:5927), Coffee Spark only.
private struct SparkHeadline: View {
  var body: some View {
    HStack(spacing: 10) {
      // Material Symbols "coffee".
      Image(systemName: "cup.and.saucer")
        .font(.system(size: 20, weight: .medium))
      Text("Coffee Spark")
        .font(.custom("JetBrainsMono-Medium", size: 20, relativeTo: .title3))
    }
    .foregroundStyle(Color(demoHex: 0x1C1B1B))
    .padding(.horizontal, 16)
    .frame(height: 48)
    .background(.white, in: RoundedRectangle(cornerRadius: 24))
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier("headline")
  }
}

/// Figma "inputs": a 16-point stack, drawn as a card with a hard offset shadow in Doggo.
private struct DemoCard<Content: View>: View {
  let theme: DemoTheme
  let content: () -> Content

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: theme.cardCornerRadius)
    VStack(alignment: .leading, spacing: 16, content: content)
      .padding(theme.cardPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background {
        if let fill = theme.cardFill {
          shape.fill(fill)
        }
      }
      .overlay {
        if let stroke = theme.cardStroke {
          shape.strokeBorder(stroke.color, lineWidth: stroke.width)
        }
      }
      .hardShadow(theme.cardShadow, shape: shape)
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier("inputs")
  }
}

extension View {
  /// The width every demo screen's content takes: inset 32 points from the sheet's edges, and
  /// no wider than 480 points so it doesn't stretch on iPad. Narrower than the Figma frames'
  /// 49-point inset, which left too little room on phones.
  func demoContentWidth() -> some View {
    frame(maxWidth: 480)
      .padding(.horizontal, 32)
  }

  /// A Figma drop shadow with zero blur: an offset copy of the shape drawn behind the view.
  @ViewBuilder
  func hardShadow(_ shadow: DemoTheme.Shadow?, shape: some Shape) -> some View {
    if let shadow {
      background {
        shape.fill(shadow.color).offset(x: shadow.x, y: shadow.y)
      }
    } else {
      self
    }
  }

  func demoText(_ token: DemoTheme.TextToken,
                relativeTo style: Font.TextStyle = .body) -> some View {
    font(token.font(relativeTo: style))
      .foregroundStyle(token.color)
      .underline(token.underline)
  }
}

/// Figma "text-field": 56 points tall with a 48-point leading icon slot. `icon` is an SF Symbol
/// standing in for the Material Symbols glyph named in Figma.
struct DemoTextField: View {
  var icon: String?
  let placeholder: String
  @Binding var text: String
  var isSecure = false
  var keyboard: UIKeyboardType = .default
  var contentType: UITextContentType?
  var identifier: String

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo
  @State private var isRevealed = false

  var body: some View {
    let theme = themeID.theme
    let shape = RoundedRectangle(cornerRadius: theme.fieldCornerRadius)
    HStack(spacing: 0) {
      if let icon {
        Image(systemName: icon)
          .font(.system(size: 20, weight: theme.fieldIconWeight))
          .foregroundStyle(theme.fieldIcon)
          .frame(width: 48, height: 48)
      }
      Group {
        if isSecure, !isRevealed {
          SecureField(text: $text) { placeholderText(theme) }
        } else {
          TextField(text: $text) { placeholderText(theme) }
        }
      }
      .font(theme.fieldText.font())
      .foregroundStyle(theme.fieldText.color)
      .tint(theme.fieldText.color)
      .keyboardType(keyboard)
      .textContentType(contentType)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
      .padding(.leading, icon == nil ? 16 : 0)
      .accessibilityIdentifier(identifier)
      if isSecure {
        Button {
          isRevealed.toggle()
        } label: {
          Image(systemName: isRevealed ? "eye" : "eye.slash")
            .foregroundStyle(theme.fieldTrailingIcon)
            .frame(width: 48, height: 48)
        }
        .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
        .accessibilityIdentifier("trailing-icon")
      }
    }
    .padding(.vertical, 4)
    .padding(.trailing, isSecure ? 0 : 16)
    .frame(minHeight: 56)
    .background(theme.fieldFill, in: shape)
    .overlay {
      shape.strokeBorder(theme.fieldStroke.color, lineWidth: theme.fieldStroke.width)
    }
  }

  private func placeholderText(_ theme: DemoTheme) -> Text {
    Text(placeholder).foregroundStyle(theme.fieldPlaceholder)
  }
}

/// Figma "button": 64 points tall and as wide as the form.
struct DemoButton: View {
  enum Kind {
    case primary
    case secondary
  }

  let title: String
  var kind: Kind = .primary
  var isLoading = false
  var identifier: String
  let action: () -> Void

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo
  @Environment(\.isEnabled) private var isEnabled

  var body: some View {
    let theme = themeID.theme
    let colors = kind == .primary ? theme.primaryButton : theme.secondaryButton
    let shape = RoundedRectangle(cornerRadius: theme.buttonCornerRadius)
    Button(action: action) {
      ZStack {
        Text(title)
          .font(theme.buttonFont.font(relativeTo: .title3))
          .opacity(isLoading ? 0 : 1)
        if isLoading {
          ProgressView().tint(colors.label)
        }
      }
      .foregroundStyle(colors.label)
      .padding(.horizontal, 24)
      .frame(maxWidth: .infinity, minHeight: theme.buttonHeight)
      .background(colors.fill, in: shape)
      .overlay {
        if let stroke = theme.buttonStroke {
          shape.strokeBorder(stroke.color, lineWidth: stroke.width)
        }
      }
      .hardShadow(theme.buttonShadow, shape: shape)
      // Composited first, so the shadow doesn't show through the faded fill.
      .compositingGroup()
      .opacity(isEnabled ? 1 : 0.5)
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(identifier)
  }
}

/// Figma "Forgot password?": a text link in the theme's link style.
struct DemoLink: View {
  let title: String
  var alignment: Alignment = .trailing
  var identifier: String
  let action: () -> Void

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo
  @Environment(\.isEnabled) private var isEnabled

  private var textAlignment: TextAlignment {
    switch alignment {
    case .center: .center
    case .trailing: .trailing
    default: .leading
    }
  }

  var body: some View {
    Button(action: action) {
      Text(title)
        .demoText(themeID.theme.link)
        .multilineTextAlignment(textAlignment)
        .opacity(isEnabled ? 1 : 0.5)
        // A taller tap area than the text, without changing the layout.
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .padding(.vertical, -8)
    }
    .buttonStyle(.plain)
    .frame(maxWidth: .infinity, alignment: alignment)
    .accessibilityIdentifier(identifier)
  }
}

/// Supporting copy on the screens Figma doesn't cover, in the "Other sign in methods" style.
struct DemoBodyText: View {
  let text: String

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  init(_ text: String) {
    self.text = text
  }

  var body: some View {
    Text(text)
      .demoText(themeID.theme.body)
      .fixedSize(horizontal: false, vertical: true)
  }
}

/// A slot's `errorMessage`, set in the library's typography with `.authFont(_:weight:)`.
struct DemoErrorText: View {
  let message: String?

  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    if let message {
      Text(message)
        .authFont(.footnote)
        .foregroundStyle(themeID.theme.errorColor)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("error-message")
    }
  }
}

/// Switches the demo's theme live from any screen, like the web demo's switcher.
struct DemoThemeMenu: View {
  @AppStorage(DemoThemeID.storageKey) private var themeID: DemoThemeID = .doggo

  var body: some View {
    Menu {
      Picker("Theme", selection: $themeID) {
        ForEach(DemoThemeID.allCases) { theme in
          Text(theme.label).tag(theme)
        }
      }
    } label: {
      Image(systemName: "paintpalette")
        .foregroundStyle(Color(UIColor.label))
    }
    .accessibilityLabel("Theme")
    .accessibilityIdentifier("theme-switcher")
  }
}
