import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftUI

@MainActor
public struct PhoneAuthButtonView {
  @Environment(AuthService.self) private var authService

  public init() {}
}

extension PhoneAuthButtonView: View {
  public var body: some View {
    Button(action: {
      authService.authView = .phoneAuth
    }) {
      Label("Sign in with Phone", systemImage: "phone.fill")
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.8)) // Light green
        .cornerRadius(8)
    }
  }
}

#Preview {
  FirebaseOptions.dummyConfigurationForPreview()
  return PhoneAuthButtonView()
    .environment(AuthService())
}
