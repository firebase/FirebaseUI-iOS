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
        AuthenticationScreen().environment(AuthEnvironment.shared)
      }
    }
  }
}
