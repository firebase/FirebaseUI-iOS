//
//  UITestUtils.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 16/05/2025.
//
import FirebaseAuth
import SwiftUI

// UI Test Runner keys
public let uiAuthEmulator = CommandLine.arguments.contains("--auth-emulator")

public var testEmail: String? {
  guard let emailIndex = CommandLine.arguments.firstIndex(of: "--create-user"),
        CommandLine.arguments.indices.contains(emailIndex + 1)
  else { return nil }
  return CommandLine.arguments[emailIndex + 1]
}

func testCreateUser() async throws {
  if let email = testEmail {
    let password = "123456"
    let auth = Auth.auth()
    try await auth.createUser(withEmail: email, password: password)
    try auth.signOut()
  }
}
