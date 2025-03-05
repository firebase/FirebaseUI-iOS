// The Swift Programming Language
// https://docs.swift.org/swift-book

import FirebaseAuth
import FirebaseAuthSwiftUI

class EmailAuthProvider: FUIAuthProvider {
  var providerId: String {
    return "password"
  }
}
