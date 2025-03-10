//
//  FirebaseSwiftUIExampleApp.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 18/02/2025.
//

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
import FirebaseEmailAuthSwiftUI
import SwiftData
import SwiftUI

struct CustomTextModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.headline)
      .background(.red)
  }
}

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
        FUIAuthView(
          FUIAuth: firebaseAuthUI,
          // method 1 of setting view modifier
          authPickerView: AuthPickerView(title: "Custom Auth Picker", textModifier: { Text in
            Text.bold()
          }) {
            VStack {
              // method 2 of setting view modifier
              EmailAuth(emailAuthButton: EmailAuthButton<
                CustomTextModifier,
                EmailAuthButtonModifier,
                EmailAuthVStackModifier
              >(buttonModifier: CustomTextModifier()))
            }
          }
        )
      }
    }
  }
}
