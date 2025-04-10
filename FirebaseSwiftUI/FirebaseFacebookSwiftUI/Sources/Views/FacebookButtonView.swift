import AppTrackingTransparency
import FacebookCore
import FacebookLogin
import FirebaseAuth
import FirebaseAuthSwiftUI
import SwiftUI

@MainActor
public struct FacebookButtonView {
  @Environment(AuthService.self) private var authService
  @State private var errorMessage = ""
  @State private var showCanceledAlert = false
  @State private var showUserTrackingAlert = false
  @State private var limitedLogin = true

  public init() {}

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

extension FacebookButtonView: View {
  public var body: some View {
    Button(action: {
      Task {
        do {
          try await authService.signInWithFacebook(limitedLogin: limitedLogin)
        } catch {
          switch error {
          case FacebookProviderError.signInCancelled:
            showCanceledAlert = true
          default:
            errorMessage = authService.string.localizedErrorMessage(for: error)
          }
        }
      }
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
        HStack {
          Spacer() // This will push the text to the left of the toggle
          Text("Limited Login")
            .foregroundColor(.blue)
        }
      }
      .toggleStyle(SwitchToggleStyle(tint: .green))
      .alert(isPresented: $showUserTrackingAlert) {
        Alert(
          title: Text("Authorize User Tracking"),
          message: Text("For classic Facebook login, please authorize user tracking."),
          dismissButton: .default(Text("OK"))
        )
      }
    }
    Text(errorMessage).foregroundColor(.red)
  }
}
