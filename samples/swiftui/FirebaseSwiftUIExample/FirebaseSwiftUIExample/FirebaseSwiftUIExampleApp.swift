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

  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Item.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      // Put this at top level so user can control it in their app
      NavigationView {
        let firebaseAuthUI = FirebaseAuthSwiftUI()
        FUIAuthView(FUIAuth: firebaseAuthUI)
      }
    }
    .modelContainer(sharedModelContainer)
  }
}
