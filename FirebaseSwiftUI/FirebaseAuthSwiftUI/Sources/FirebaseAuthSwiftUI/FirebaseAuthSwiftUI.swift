// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import FirebaseAuth
import Combine


public protocol AuthListenerProtocol {
    func onError(_ error: Error)
    func onBeforeSignIn()
    func onSignedIn(_ user: User)
    func onCanceled()
    func onCredentialReceived(_ credential: AuthCredential)
    func onCredentialLinked(_ credential: AuthCredential)
    // TODO - add when I get to this point
    // func onMFARequired(_ resolver: MultiFactorResolver)
}

public protocol AuthProviderProtocol {
    associatedtype Listener: AuthListenerProtocol
    associatedtype Credential: AuthCredential
    
    var auth: Auth { get }
    var authListener: Listener { get set }
    var providerId: String { get }
    
    func signInWithCredential(_ credential: Credential)
    func linkWithCredential(_ credential: Credential)
}

public enum AuthAction {
    /// Performs user sign in
    case signIn

    /// Creates a new account with for a provided credential
    case signUp

    /// Links a provided credential with currently signed in user account
    case link

    /// Disables automatic credential handling.
    /// It's up to the user to decide what to do with the obtained credential.
    case none
}

open class AuthProvider<Listener: AuthListenerProtocol>: AuthProviderProtocol {
  public var auth: Auth = Auth.auth()
  public var authListener: Listener
  public var providerId: String
    
  public init(listener: Listener, providerId: String) {
        self.authListener = listener
        self.providerId = providerId
    }
  
  var shouldUpgradeAnonymous: Bool {
      return Auth.auth().currentUser?.isAnonymous ?? false
  }
    
  public func signInWithCredential(_ credential: AuthCredential) {
        authListener.onBeforeSignIn()
        auth.signIn(with: credential) { [weak self] result, error in
            if let error = error {
                self?.authListener.onError(error)
            } else if let user = result?.user {
                self?.authListener.onSignedIn(user)
            }
        }
    }
    
  public func linkWithCredential(_ credential: AuthCredential) {
        authListener.onCredentialReceived(credential)
        guard let user = auth.currentUser else { return }
        
        user.link(with: credential) { [weak self] result, error in
            if let error = error {
                self?.authListener.onError(error)
            } else {
                self?.authListener.onCredentialLinked(credential)
            }
        }
    }
  
  func onCredentialReceived(credential: AuthCredential, action: AuthAction) {
      switch action {
      case .link:
          linkWithCredential(credential)
      case .signIn, .signUp:
          // Only email provider has a different action for sign in and sign up
          // and implements its own sign up logic.
          if shouldUpgradeAnonymous {
              linkWithCredential(credential)
          } else {
              signInWithCredential(credential)
          }
      case .none:
          authListener.onCredentialReceived(credential)
      }
  }
    // TODO - fetchSignInMethodsForEmail/fetchProvidersForEmail is deprecated
}

