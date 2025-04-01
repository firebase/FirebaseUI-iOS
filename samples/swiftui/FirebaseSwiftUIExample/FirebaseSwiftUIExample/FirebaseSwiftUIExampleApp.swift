//
//  FirebaseSwiftUIExampleApp.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 18/02/2025.
//

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
import FirebaseGoogleSwiftUI
import SwiftData
import SwiftUI

let googleProvider = GoogleProviderSwift()

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_: UIApplication,
                   open url: URL,
                   options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return googleProvider.handleUrl(url)
  }
}

@main
struct FirebaseSwiftUIExampleApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
  let authService: AuthService

  init() {
    authService = AuthService()
  }

  var body: some View {
    AuthPickerView {
      Text("GOOGLE AUTH BUTTON")
    }.environment(authService)
  }
}
