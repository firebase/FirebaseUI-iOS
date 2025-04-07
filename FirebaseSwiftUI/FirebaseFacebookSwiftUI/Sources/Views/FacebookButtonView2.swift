import AppTrackingTransparency
import FacebookCore
import FacebookLogin
import FirebaseAuth
import FirebaseAuthSwiftUI
import SwiftUI

@MainActor
public struct FacebookButtonView2 {
  @Environment(AuthService.self) private var authService
  @State private var errorMessage = ""
  @State private var limitedLogin: Bool = true
  @State private var showCanceledAlert = false
  @State private var showUserTrackingAlert = false

  private var rawNonce: String
  private var shaNonce: String
  private let loginManager = LoginManager()

  public init() {
    rawNonce = FacebookUtils.randomNonce()
    shaNonce = FacebookUtils.sha256Hash(of: rawNonce)
  }

  private var trackingPreference: LoginTracking {
    // if not authorized, Facebook will default to limited login and classic login will fail
    let trackingStatus = ATTrackingManager.trackingAuthorizationStatus
    if trackingStatus != .authorized {
      return .limited
    }

    return limitedLogin ? .limited : .enabled
  }

  var configuration: LoginConfiguration? {
    if trackingPreference == .limited {
      return LoginConfiguration(
        permissions: [.publicProfile, .email],
        tracking: trackingPreference,
        nonce: shaNonce
      )
    }
    return LoginConfiguration(
      permissions: [.publicProfile, .email],
      tracking: trackingPreference
    )
  }

  func invokeLoginMethod() {
    let validConfiguration = configuration
    if validConfiguration != nil {
      loginManager.logIn(
        configuration: validConfiguration
      ) { result in
        switch result {
        case .cancelled:
          showCanceledAlert = true
        case let .failed(error):
          errorMessage = authService.string.localizedErrorMessage(for: error)
        case .success:
          if trackingPreference == .limited {
            Task {
              await limitedLogin()
            }
          } else {
            Task {
              await classicLogin()
            }
          }
        }
      }
    } else {
      errorMessage = "Facebook configuration is invalid."
    }
  }

  private func classicLogin() async {
    do {
      if let token = AccessToken.current,
         !token.isExpired {
        let credential = FacebookAuthProvider
          .credential(withAccessToken: token.tokenString)
        try await authService.signIn(with: credential)
      } else {
        throw NSError(
          domain: "FacebookSwiftErrorDomain",
          code: 1,
          userInfo: [
            NSLocalizedDescriptionKey: "Access token has expired or not available. Please sign-in with Facebook before attempting to create a Facebook provider credential",
          ]
        )
      }
    } catch {
      errorMessage = authService.string.localizedErrorMessage(
        for: error
      )
    }
  }

  private func limitedLogin() async {
    do {
      if let idToken = AuthenticationToken.current {
        let credential = OAuthProvider.credential(withProviderID: kFacebookProviderId,
                                                  idToken: idToken.tokenString,
                                                  rawNonce: rawNonce)
        try await authService.signIn(with: credential)
      } else {
        throw NSError(
          domain: "FacebookSwiftErrorDomain",
          code: 2,
          userInfo: [
            NSLocalizedDescriptionKey: "Authentication is not available. Please sign-in with Facebook before attempting to create a Facebook provider credential",
          ]
        )
      }
    } catch {
      errorMessage = authService.string.localizedErrorMessage(
        for: error
      )
    }
  }

  private var limitedLoginBinding: Binding<Bool> {
    Binding(
      get: { self.limitedLogin },
      set: { newValue in
        let trackingStatus = ATTrackingManager.trackingAuthorizationStatus

        if newValue == true, trackingStatus != .authorized {
          self.showUserTrackingAlert = true
        } else {
          self.limitedLogin = newValue
        }
      }
    )
  }

  func requestTrackingPermission() {
    ATTrackingManager.requestTrackingAuthorization { status in
      switch status {
      case .authorized:
        print("Tracking authorized")
      case .denied, .restricted, .notDetermined:
        print("Tracking not authorized")
      @unknown default:
        print("Unknown status")
      }
    }
  }
}

extension FacebookButtonView2: View {
  public var body: some View {
    Button(action: {
      invokeLoginMethod()
    }) {
      HStack {
        Image(systemName: "f.circle.fill")
          .font(.title)
          .foregroundColor(.white)
        Text("Continue with Facebook")
          .fontWeight(.semibold)
          .foregroundColor(.white)
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(Color.blue)
      .cornerRadius(8)
    }
    .alert(isPresented: $showCanceledAlert) {
      Alert(
        title: Text("Facebook login cancelled"),
        dismissButton: .default(Text("OK"))
      )
    }
    HStack {
      Text("Authorize User Tracking")
        .font(.footnote)
        .foregroundColor(.blue)
        .underline()
        .onTapGesture {
          requestTrackingPermission()
        }
      Toggle(isOn: limitedLoginBinding) {
        Text("Limited Login")
          .foregroundColor(.green)
      }
      .toggleStyle(SwitchToggleStyle(tint: .green))
      .alert(isPresented: $showUserTrackingAlert) {
        Alert(
          title: Text("Authorise User Tracking"),
          message: Text("For classic Facebook login, please authorize user tracking."),
          dismissButton: .default(Text("OK"))
        )
      }
    }
    Text(errorMessage).foregroundColor(.red)
  }
}
