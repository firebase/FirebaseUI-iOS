import FirebaseAuth

public protocol FUIAuthProvider {
  var providerId: String { get }
  var shortName: String { get }
  // TODO: - put customisable UI on the appropriate View
//  var signInLabel: String { get }
//  var icon: UIImage { get }
//  var buttonBackgroundColor: UIColor { get }
//  var buttonTextColor: UIColor { get }
//  var buttonAlignment: Alignment { get set }
  var accessToken: String? { get }
  var idToken: String? { get }

  // State properties passed upwards
  var credential: AuthCredential? { get set }
  var error: Error? { get set }
  var userInfo: [String: Any]? { get set }
  var isAuthenticated: Bool { get set }

  func signOut()

  func email() -> String

  // Removed handleOpenURL method as SwiftUI uses onOpenURL which is a view modifier
}
