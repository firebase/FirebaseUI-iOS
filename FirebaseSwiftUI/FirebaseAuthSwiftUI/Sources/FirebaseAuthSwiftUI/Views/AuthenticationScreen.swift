import FirebaseAuth
import SwiftUI

enum AuthenticationFlow {
  case login
  case signUp
}

public struct AuthenticationScreen {
  @Environment(AuthEnvironment.self) private var authEnvironment

  @State private var flow: AuthenticationFlow = .login

  private func switchFlow() {
    flow = flow == .login ? .signUp : .login
    errorMessage = ""
  }

  @State private var errorMessage = ""
}

extension AuthenticationScreen: View {
  public var body: some View {
    VStack {
      Text("Authentication screen")
    }
  }
}
