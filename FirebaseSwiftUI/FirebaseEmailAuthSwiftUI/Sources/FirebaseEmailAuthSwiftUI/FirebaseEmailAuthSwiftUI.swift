// The Swift Programming Language
// https://docs.swift.org/swift-book

import FirebaseAuthSwiftUI
import FirebaseAuth

class EmailAuthProvider: FUIAuthProvider {
  var providerId: String {
      return "password"
  }
  
}
