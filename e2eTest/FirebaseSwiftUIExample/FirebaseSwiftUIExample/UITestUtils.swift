//
//  UITestUtils.swift
//  FirebaseSwiftUIExample
//
//  Created by Russell Wheatley on 16/05/2025.
//
import FirebaseAuth
import SwiftUI

// UI Test Runner keys
public let testRunner = CommandLine.arguments.contains("--test-view-enabled")

public let anonymousSignInEnabled = CommandLine.arguments.contains("--anonymous-sign-in-enabled")

func signOut() throws {
  try Auth.auth().signOut()
}
