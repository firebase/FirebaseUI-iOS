//
//  FirebaseSwiftUIExampleApp.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 18/02/2025.
//

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
import SwiftData
import SwiftUI

@main
struct FirebaseSwiftUIExampleApp: App {
  init() {
    FirebaseApp.configure()
  }

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}

struct ContentView: View {
  let authEnvironment: AuthEnvironment
  let emailAuthProvider: EmailPasswordAuthProvider

  init() {
    emailAuthProvider = EmailPasswordAuthProvider()
    authEnvironment = AuthEnvironment(emailAuthProvider: emailAuthProvider)
  }

  var body: some View {
    AuthPickerView {
      EmailPasswordButtonView()
    }.environment(authEnvironment)
  }
}
