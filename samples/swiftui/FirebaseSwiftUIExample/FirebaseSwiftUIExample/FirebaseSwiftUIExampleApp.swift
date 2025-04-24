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
import FirebasePhoneAuthSwiftUI
import FirebaseTwitterSwiftUI
import SwiftData
import SwiftUI

let googleProvider = GoogleProviderSwift()

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [
                     UIApplication.LaunchOptionsKey: Any
                   ]?) -> Bool {
    FirebaseApp.configure()
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    return true
  }

  func application(_: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Auth.auth().setAPNSToken(deviceToken, type: .prod)
  }

  func application(_: UIApplication, didReceiveRemoteNotification notification: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                     -> Void) {
    if Auth.auth().canHandleNotification(notification) {
      completionHandler(.noData)
      return
    }
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

  init() {}

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
    // Auth.auth().signInAnonymously()

    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings
      .url = URL(string: "https://flutterfire-e2e-tests.firebaseapp.com")
    actionCodeSettings.linkDomain = "flutterfire-e2e-tests.firebaseapp.com"
    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    let configuration = AuthConfiguration(
      shouldAutoUpgradeAnonymousUsers: true,
      emailLinkSignInActionCodeSettings: actionCodeSettings
    )
    let facebookProvider = FacebookProviderSwift()
    let phoneAuthProvider = PhoneAuthProviderSwift()
    let twitterProvider = TwitterProviderSwift()
    authService = AuthService(
      configuration: configuration,
      googleProvider: googleProvider,
      facebookProvider: facebookProvider,
      phoneAuthProvider: phoneAuthProvider,
      twitterProvider: twitterProvider
    )
  }

  var body: some View {
    AuthPickerView {
      SignInWithGoogleButton()
      SignInWithFacebookButton()
      SignInWithTwitterButton()
      PhoneAuthButtonView()
    }.environment(authService)
  }
}
