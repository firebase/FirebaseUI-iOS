//
//  FirebaseSwiftUIExampleApp.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 18/02/2025.
//

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
import FirebaseEmailAuthUI
import SwiftData
import SwiftUI

@main
struct FirebaseSwiftUIExampleApp: App {
  init() {
    FirebaseApp.configure()
  }

  var body: some Scene {
    WindowGroup {
      // Put this at top level so user can control it in their app
      NavigationView {
        let firebaseAuthUI = FUIAuth()
        FUIAuthView(FUIAuth: firebaseAuthUI) {
          VStack {
            // TODO: - populate with auth views here
          }
        }
      }
    }
  }
}
