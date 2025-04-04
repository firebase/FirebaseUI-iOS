//
//  FirebaseSwiftUIExampleApp.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 18/02/2025.
//

import FacebookCore
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
import FirebaseFacebookSwiftUI
import FirebaseGoogleSwiftUI
import SwiftData
import SwiftUI

let googleProvider = GoogleProviderSwift()

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [
                     UIApplication.LaunchOptionsKey: Any
                   ]?) -> Bool {
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    return true
  }

  func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    ApplicationDelegate.shared.application(
      app,
      open: url,
      sourceApplication: options[UIApplication.OpenURLOptionsKey
        .sourceApplication] as? String,
      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
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
    authService = AuthService(googleProvider: googleProvider)
  }

  var body: some View {
    AuthPickerView {
      GoogleButtonView()
      FacebookButtonView()
    }.environment(authService)
  }
}
