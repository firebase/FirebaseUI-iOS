//
//  FirebaseSwiftUIExampleTests.swift
//  FirebaseSwiftUIExampleTests
//
//  Created by Russell Wheatley on 18/02/2025.
//
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseCore
@testable import FirebaseSwiftUIExample
import Testing

let kEmailAddress = "test@example.com"
let kPassword = "123456"

struct FirebaseSwiftUIExampleTests {
  @MainActor
  func prepareFreshAuthService(configuration: AuthConfiguration? = nil) async throws
    -> AuthService {
    configureFirebaseIfNeeded()
    try await clearAuthEmulatorState()

    let resolvedConfiguration = configuration ?? AuthConfiguration()

    return AuthService(configuration: resolvedConfiguration)
  }

  @Test
  @MainActor
  func testCreateEmailPasswordUser() async throws {
    let service = try await prepareFreshAuthService()

    #expect(service.authenticationState == .unauthenticated)
    #expect(service.authView == .authPicker)
    #expect(service.errorMessage.isEmpty)
    #expect(service.signedInCredential == nil)
    #expect(service.currentUser == nil)
    try await service.createUser(withEmail: kEmailAddress, password: kPassword)

    #expect(service.authenticationState == .authenticated)
    #expect(service.authView == .authPicker)
    #expect(service.errorMessage.isEmpty)
    #expect(service.currentUser != nil)
    // TODO: - reinstate once this PR is merged: https://github.com/firebase/FirebaseUI-iOS/pull/1256
//    #expect(service.signedInCredential is AuthCredential)
  }

  @Test
  @MainActor
  func testSignInUser() async throws {
    let service = try await prepareFreshAuthService()
    // TODO: - it clears emulator data but seems like it is still there?
//    try await service.createUser(withEmail: kEmailAddress, password: kPassword)
//    try await service.signOut()
    #expect(service.authenticationState == .unauthenticated)
    #expect(service.authView == .authPicker)
    #expect(service.errorMessage.isEmpty)
    #expect(service.signedInCredential == nil)
    #expect(service.currentUser == nil)

    try await service.signIn(withEmail: kEmailAddress, password: kPassword)

    #expect(service.authenticationState == .authenticated)
    #expect(service.authView == .authPicker)
    #expect(service.errorMessage.isEmpty)
    #expect(service.currentUser != nil)
    // TODO: - reinstate once this PR is merged: https://github.com/firebase/FirebaseUI-iOS/pull/1256
//    #expect(service.signedInCredential is AuthCredential)
  }
}
