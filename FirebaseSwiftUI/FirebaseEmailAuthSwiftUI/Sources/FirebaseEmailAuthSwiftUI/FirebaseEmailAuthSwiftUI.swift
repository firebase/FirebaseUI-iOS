// The Swift Programming Language
// https://docs.swift.org/swift-book

import FirebaseAuthSwiftUI
import FirebaseAuth

class EmailAuthProvider<Listener: AuthListenerProtocol>: AuthProvider<Listener> {
   init(listener: Listener) {
      super.init(listener: listener, providerId: "password")
   }
  
  func signUpWithEmailAndPassword(email: String, password: String) {
    self.authListener.onBeforeSignIn()
    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle error
              self.authListener.onError(error)
            } else if let authResult = authResult {
                // Notify listener on successful sign-in
              self.authListener.onSignedIn(authResult.user)
            }
        }
  }
}
