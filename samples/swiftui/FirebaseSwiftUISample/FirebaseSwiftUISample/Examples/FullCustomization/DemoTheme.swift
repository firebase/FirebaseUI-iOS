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

/// The looks of the full customization demo. Doggo, Grid and Coffee Spark come from the iOS
/// Landing frames in the "Firebase auth flows" Figma file (17:12933, 20:5467 and 20:5769), and
/// screens the frames don't cover reuse their values. Professional has no Figma frame: its values
/// are a written spec in ``DemoTheme/professional``.
enum DemoThemeID: String, CaseIterable, Identifiable {
  case doggo
  case grid
  case spark
  case professional

  static let storageKey = "fullCustomization.theme"

  var id: String { rawValue }

  var label: String {
    switch self {
    case .doggo: "Doggo"
    case .grid: "Grid"
    case .spark: "Coffee Spark"
    case .professional: "Professional"
    }
  }

  var theme: DemoTheme {
    switch self {
    case .doggo: .doggo
    case .grid: .grid
    case .spark: .spark
    case .professional: .professional
    }
  }
}

struct DemoTheme {
  struct TextToken {
    /// A bundled font's PostScript name, or `nil` for the system font at ``weight``.
    var fontName: String?
    var size: CGFloat
    var weight: Font.Weight = .regular
    var color: Color
    var underline = false

    func font(relativeTo style: Font.TextStyle = .body) -> Font {
      if let fontName {
        .custom(fontName, size: size, relativeTo: style)
      } else {
        .system(size: size, weight: weight)
      }
    }
  }

  struct ButtonColors {
    var fill: Color
    var label: Color
  }

  struct Shadow {
    var color: Color
    var x: CGFloat
    var y: CGFloat
  }

  struct Stroke {
    var color: Color
    var width: CGFloat
  }

  struct Provider {
    var fill: Color
    var label: DemoTheme.TextToken
    var cornerRadius: CGFloat
  }

  let id: DemoThemeID
  /// The family handed to `AuthTypography`, so library screens the demo doesn't replace (update
  /// password, reauthentication, delete confirmation) use the theme's font too. `nil` keeps the
  /// system font.
  let libraryFontFamily: String?
  let pageBackground: Color

  /// The "title" text above the form. Coffee Spark hides it in Figma and shows ``headline``.
  let title: TextToken
  let showsTitle: Bool
  /// Space between the title and the form: the "sign up" frame's title-to-inputs offset.
  let titleSpacing: CGFloat

  /// The "inputs" frame: Doggo draws it as a card; Grid and Coffee Spark leave it bare.
  let cardFill: Color?
  let cardCornerRadius: CGFloat
  let cardPadding: CGFloat
  let cardShadow: Shadow?
  let cardStroke: Stroke?

  /// The "text-field" instance.
  let fieldFill: Color
  let fieldStroke: Stroke
  let fieldCornerRadius: CGFloat
  let fieldText: TextToken
  let fieldPlaceholder: Color
  let fieldIcon: Color
  let fieldIconWeight: Font.Weight
  let fieldTrailingIcon: Color

  let link: TextToken

  /// The "button" instances: primary is "Login", secondary is "Email link sign-in".
  let buttonFont: TextToken
  let buttonCornerRadius: CGFloat
  let buttonHeight: CGFloat
  let buttonStroke: Stroke?
  let buttonShadow: Shadow?
  let primaryButton: ButtonColors
  let secondaryButton: ButtonColors

  /// The "Content" frame below the form.
  let dividerColor: Color
  let otherLabel: TextToken
  let otherPadding: EdgeInsets
  let googleLabel: TextToken
  /// The Google and "More sign-in options" pills.
  let pillFill: Color
  let pillCornerRadius: CGFloat
  let pillStroke: Color
  let phoneProvider: Provider
  let footerText: TextToken
  let footerAccent: TextToken

  let errorColor = Color(demoHex: 0xBA1A1A)

  var body: TextToken { otherLabel }
}

extension DemoTheme {
  /// Figma 17:12933 "Landing".
  static let doggo = DemoTheme(
    id: .doggo,
    libraryFontFamily: "Onest",
    pageBackground: Color(demoHex: 0xFFF8F8),
    title: TextToken(fontName: "BagelFatOne-Regular", size: 28, color: Color(demoHex: 0x864B6F)),
    showsTitle: true,
    titleSpacing: 12,
    cardFill: Color(demoHex: 0xFFF8F8),
    cardCornerRadius: 24,
    cardPadding: 16,
    cardShadow: Shadow(color: Color(demoHex: 0xFFD8EB), x: 3, y: 6),
    cardStroke: nil,
    fieldFill: .white,
    fieldStroke: Stroke(color: Color(demoHex: 0xD3C2C9), width: 1),
    fieldCornerRadius: 24,
    fieldText: TextToken(fontName: "Onest-Medium", size: 16, color: Color(demoHex: 0x211A1D)),
    fieldPlaceholder: Color(demoHex: 0xA08B95),
    fieldIcon: Color(demoHex: 0xA08B95),
    fieldIconWeight: .bold,
    fieldTrailingIcon: Color(demoHex: 0x49454F),
    link: TextToken(
      fontName: "Onest-Medium",
      size: 16,
      color: Color(demoHex: 0x864B6F),
      underline: true
    ),
    buttonFont: TextToken(fontName: "Onest-Bold", size: 20, color: .white),
    buttonCornerRadius: 36,
    buttonHeight: 64,
    buttonStroke: nil,
    buttonShadow: Shadow(color: Color(demoHex: 0x5D0B47), x: 2, y: 4),
    primaryButton: ButtonColors(fill: Color(demoHex: 0x864B6F), label: .white),
    secondaryButton: ButtonColors(fill: Color(demoHex: 0xFFD8EB), label: Color(demoHex: 0x7B3B73)),
    dividerColor: Color(demoHex: 0x864B6F),
    otherLabel: TextToken(fontName: "Onest-Medium", size: 16, color: Color(demoHex: 0xA08B95)),
    otherPadding: EdgeInsets(top: 16, leading: 40, bottom: 0, trailing: 40),
    googleLabel: TextToken(fontName: "Roboto-SemiBold", size: 14, color: .black),
    pillFill: .white,
    pillCornerRadius: 80,
    pillStroke: .black,
    phoneProvider: Provider(
      fill: Color(demoHex: 0x894680),
      label: TextToken(fontName: "Roboto-Medium", size: 14, color: .white),
      cornerRadius: 80
    ),
    footerText: TextToken(fontName: "Onest-Medium", size: 14, color: Color(demoHex: 0x202124)),
    footerAccent: TextToken(fontName: "Onest-Bold", size: 14, color: Color(demoHex: 0x894680))
  )

  /// Figma 20:5467 "iOS Landing" with the grid background.
  static let grid = DemoTheme(
    id: .grid,
    libraryFontFamily: "Chivo Mono",
    pageBackground: Color(demoHex: 0xF3FBFB),
    title: TextToken(fontName: "Rowdies-Regular", size: 28, color: Color(demoHex: 0x2C1067)),
    showsTitle: true,
    titleSpacing: 12,
    cardFill: nil,
    cardCornerRadius: 24,
    cardPadding: 0,
    cardShadow: nil,
    cardStroke: nil,
    fieldFill: .white,
    fieldStroke: Stroke(color: Color(demoHex: 0x00DCE2), width: 2),
    fieldCornerRadius: 16,
    fieldText: TextToken(fontName: "ChivoMono-Medium", size: 16, color: Color(demoHex: 0x2C1067)),
    fieldPlaceholder: Color(demoHex: 0x2C1067),
    fieldIcon: Color(demoHex: 0x2C1067),
    fieldIconWeight: .regular,
    fieldTrailingIcon: Color(demoHex: 0x2C1067),
    link: TextToken(fontName: "ChivoMono-Medium", size: 16, color: Color(demoHex: 0xFF52B3)),
    buttonFont: TextToken(fontName: "Rowdies-Bold", size: 20, color: Color(demoHex: 0x2C1067)),
    buttonCornerRadius: 24,
    buttonHeight: 64,
    buttonStroke: Stroke(color: Color(demoHex: 0x00DCE2), width: 2),
    buttonShadow: Shadow(color: Color(demoHex: 0x00DCE2), x: 3, y: 6),
    primaryButton: ButtonColors(fill: Color(demoHex: 0xFF52B3), label: Color(demoHex: 0x2C1067)),
    secondaryButton: ButtonColors(fill: Color(demoHex: 0xF3FBFB), label: Color(demoHex: 0x2C1067)),
    dividerColor: Color(demoHex: 0x864B6F),
    otherLabel: TextToken(fontName: "ChivoMono-Medium", size: 16, color: Color(demoHex: 0x2C1067)),
    otherPadding: EdgeInsets(top: 16, leading: 40, bottom: 0, trailing: 40),
    googleLabel: TextToken(fontName: "Roboto-SemiBold", size: 14, color: .black),
    pillFill: .white,
    pillCornerRadius: 80,
    pillStroke: .black,
    phoneProvider: Provider(
      fill: Color(demoHex: 0x00DCE2),
      label: TextToken(fontName: "ChivoMono-Medium", size: 14, color: Color(demoHex: 0x2C1067)),
      cornerRadius: 12
    ),
    footerText: TextToken(fontName: "ChivoMono-Medium", size: 14, color: Color(demoHex: 0x202124)),
    footerAccent: TextToken(
      fontName: "ChivoMono-Bold",
      size: 14,
      color: Color(demoHex: 0xFF52B3),
      underline: true
    )
  )

  /// Figma 20:5769 "iOS Landing" with the Coffee Spark headline.
  static let spark = DemoTheme(
    id: .spark,
    libraryFontFamily: "JetBrains Mono",
    pageBackground: Color(demoHex: 0xF1F1F1),
    // The frame's "title" text is hidden; this size is the Doggo and Grid title's, used on the
    // screens Figma doesn't cover.
    title: TextToken(fontName: "JetBrainsMono-Medium", size: 28, color: Color(demoHex: 0x1C1B1B)),
    showsTitle: false,
    titleSpacing: 12,
    cardFill: nil,
    cardCornerRadius: 24,
    cardPadding: 0,
    cardShadow: nil,
    cardStroke: nil,
    fieldFill: .white,
    fieldStroke: Stroke(color: .black, width: 2),
    fieldCornerRadius: 16,
    fieldText: TextToken(fontName: "JetBrainsMono-Medium", size: 16, color: .black),
    fieldPlaceholder: .black,
    fieldIcon: .black,
    fieldIconWeight: .regular,
    fieldTrailingIcon: .black,
    link: TextToken(fontName: "JetBrainsMono-Medium", size: 16, color: Color(demoHex: 0x34A853)),
    buttonFont: TextToken(fontName: "JetBrainsMono-Bold", size: 20, color: .black),
    buttonCornerRadius: 40,
    buttonHeight: 64,
    buttonStroke: Stroke(color: .black, width: 2),
    buttonShadow: nil,
    primaryButton: ButtonColors(fill: Color(demoHex: 0xFDADEE), label: .black),
    secondaryButton: ButtonColors(fill: Color(demoHex: 0xF3FBFB), label: .black),
    dividerColor: Color(demoHex: 0xFDFCFB),
    otherLabel: TextToken(fontName: "JetBrainsMono-Medium", size: 16, color: .black),
    otherPadding: EdgeInsets(top: 24, leading: 54, bottom: 0, trailing: 54),
    googleLabel: TextToken(fontName: "Roboto-SemiBold", size: 14, color: .black),
    pillFill: .white,
    pillCornerRadius: 80,
    pillStroke: .black,
    phoneProvider: Provider(
      fill: Color(demoHex: 0xC6FF00),
      label: TextToken(fontName: "ChivoMono-Medium", size: 14, color: Color(demoHex: 0x34A853)),
      cornerRadius: 40
    ),
    footerText: TextToken(fontName: "ChivoMono-Medium", size: 14, color: Color(demoHex: 0x202124)),
    footerAccent: TextToken(
      fontName: "ChivoMono-Bold",
      size: 14,
      color: Color(demoHex: 0x34A853),
      underline: true
    )
  )
}

extension DemoTheme {
  /// Not from Figma: a quiet, platform-native look written as a spec. The system font, neutral
  /// greys with one blue accent, 10-point corners, hairline borders instead of offset shadows,
  /// no background art, and light and dark variants.
  static let professional: DemoTheme = {
    let text = Color(demoLight: 0x111418, dark: 0xF2F4F7)
    let muted = Color(demoLight: 0x5B6470, dark: 0x9AA3AE)
    let accent = Color(demoLight: 0x1F5EFF, dark: 0x4C7DFF)
    // Darker than `accent` in dark mode so white labels on it keep 4.5:1 contrast.
    let accentFill = Color(demoLight: 0x1F5EFF, dark: 0x2F62F0)
    let hairline = Color(demoLight: 0xE3E6EA, dark: 0x2A2F36)
    return DemoTheme(
      id: .professional,
      libraryFontFamily: nil,
      pageBackground: Color(demoLight: 0xF5F6F8, dark: 0x0F1115),
      title: TextToken(size: 28, weight: .semibold, color: text),
      showsTitle: true,
      titleSpacing: 16,
      cardFill: Color(demoLight: 0xFFFFFF, dark: 0x181B20),
      cardCornerRadius: 16,
      cardPadding: 20,
      cardShadow: nil,
      cardStroke: Stroke(color: hairline, width: 1),
      fieldFill: Color(demoLight: 0xFFFFFF, dark: 0x0F1115),
      fieldStroke: Stroke(color: Color(demoLight: 0xC9CFD6, dark: 0x3A414A), width: 1),
      fieldCornerRadius: 10,
      fieldText: TextToken(size: 16, color: text),
      fieldPlaceholder: Color(demoLight: 0x6B7480, dark: 0x7D8693),
      fieldIcon: muted,
      fieldIconWeight: .regular,
      fieldTrailingIcon: muted,
      link: TextToken(size: 15, weight: .medium, color: accent),
      buttonFont: TextToken(size: 17, weight: .semibold, color: .white),
      buttonCornerRadius: 10,
      buttonHeight: 52,
      buttonStroke: nil,
      buttonShadow: nil,
      primaryButton: ButtonColors(fill: accentFill, label: .white),
      secondaryButton: ButtonColors(
        fill: Color(demoLight: 0xEEF2FF, dark: 0x1C2540),
        label: Color(demoLight: 0x1F5EFF, dark: 0x9DB5FF)
      ),
      dividerColor: hairline,
      otherLabel: TextToken(size: 15, color: muted),
      otherPadding: EdgeInsets(top: 20, leading: 24, bottom: 0, trailing: 24),
      googleLabel: TextToken(size: 15, weight: .semibold, color: text),
      pillFill: Color(demoLight: 0xFFFFFF, dark: 0x181B20),
      pillCornerRadius: 10,
      pillStroke: Color(demoLight: 0xC9CFD6, dark: 0x3A414A),
      phoneProvider: Provider(
        fill: accentFill,
        label: TextToken(size: 15, weight: .semibold, color: .white),
        cornerRadius: 10
      ),
      footerText: TextToken(size: 14, color: muted),
      footerAccent: TextToken(size: 14, weight: .semibold, color: accent)
    )
  }()
}

// MARK: - Library theming

extension DemoTheme {
  var typography: AuthTypography {
    AuthTypography(fontName: libraryFontFamily)
  }

  var textFieldStyle: AuthTextFieldStyle {
    AuthTextFieldStyle(
      tint: fieldStroke.color,
      containerColor: fieldFill,
      secondaryColor: fieldPlaceholder,
      errorColor: errorColor,
      cornerRadius: fieldCornerRadius
    )
  }

  var ctaButtonStyle: AuthCTAButtonStyle {
    AuthCTAButtonStyle(
      backgroundColor: primaryButton.fill,
      contentColor: primaryButton.label,
      shape: .roundedRectangle(radius: buttonCornerRadius),
      font: buttonFont.font()
    )
  }
}

// MARK: - Background art

/// The background layers of each frame, placed at their Figma offsets from the frame's top-left
/// corner: "bg" and "pattern" in Doggo, "Frame 5" in Grid and "avatar spark" in Coffee Spark.
struct DemoThemeBackground: View {
  let theme: DemoTheme

  var body: some View {
    // An overlay, so the art larger than the screen doesn't size the background itself.
    theme.pageBackground
      .overlay(alignment: .topLeading) { art }
      .clipped()
      .ignoresSafeArea()
      .accessibilityHidden(true)
  }

  private var art: some View {
    ZStack(alignment: .topLeading) {
      switch theme.id {
      case .doggo:
        DoggoGradient()
          .frame(width: 441.481, height: 934.09)
          .offset(x: -8, y: 0)
        art("doggo-pattern", x: -160, y: -680, width: 1031, height: 1042)
      case .grid:
        art("grid-pattern", x: -269, y: -75, width: 997, height: 997)
      case .spark:
        // The export includes the layer's texture and noise effects, so it is larger than the
        // 583x568 layer; it is centred on the layer's bounds.
        art("spark-blob", x: -295.8, y: -317.7, width: 751, height: 735.3)
      case .professional:
        EmptyView()
      }
    }
  }

  private func art(_ name: String, x: CGFloat, y: CGFloat, width: CGFloat,
                   height: CGFloat) -> some View {
    Image("FullCustomization/\(name)")
      .resizable()
      .frame(width: width, height: height)
      .offset(x: x, y: y)
      .accessibilityIdentifier(name)
  }
}

/// Figma "bg" (17:12934): a radial gradient whose ellipse is given by three handle points in the
/// layer's unit square, drawn by mapping a unit circle onto that ellipse.
private struct DoggoGradient: View {
  var body: some View {
    Canvas { context, size in
      let origin = CGPoint(x: -0.03 * size.width, y: 0)
      let axisX = CGPoint(x: 0.95 * size.width - origin.x, y: 0.55 * size.height - origin.y)
      let axisY = CGPoint(x: -0.83 * size.width - origin.x, y: 1.08 * size.height - origin.y)
      var unit = context
      unit.transform = CGAffineTransform(
        a: axisX.x, b: axisX.y, c: axisY.x, d: axisY.y, tx: origin.x, ty: origin.y
      )
      unit.fill(
        Path(CGRect(x: -2, y: -2, width: 4, height: 4)),
        with: .radialGradient(
          Gradient(stops: [
            .init(color: Color(demoHex: 0xFFF8F8), location: 0.04),
            .init(color: Color(demoHex: 0xFFDDB4), location: 0.34),
            .init(color: Color(demoHex: 0xFFD8EB), location: 0.74),
          ]),
          center: .zero,
          startRadius: 0,
          endRadius: 1
        )
      )
    }
  }
}

extension Color {
  /// A colour that follows the system's light or dark appearance.
  init(demoLight light: UInt32, dark: UInt32) {
    self.init(UIColor { traits in
      UIColor(Color(demoHex: traits.userInterfaceStyle == .dark ? dark : light))
    })
  }

  init(demoHex hex: UInt32) {
    self.init(
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255
    )
  }
}
