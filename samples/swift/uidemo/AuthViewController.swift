//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI

let kFirebaseTermsOfService = NSURL(string: "https://firebase.google.com/terms/")!

// Your Google app's client ID, which can be found in the GoogleService-Info.plist file
// and is stored in the `clientID` property of your FIRApp options.
// Firebase Google auth is built on top of Google sign-in, so you'll have to add a URL
// scheme to your project as outlined at the bottom of this reference:
// https://developers.google.com/identity/sign-in/ios/start-integrating
//
// Make sure you don't accidentally check in your client ID in a public repo!
let kGoogleAppClientID = (FIRApp.defaultApp()?.options.clientID)!

// Your Facebook App ID, which can be found on developers.facebook.com.
let kFacebookAppID     = "your fb app ID here"

/// A view controller displaying a basic sign-in flow using FIRAuthUI.
class AuthViewController: UIViewController {
  // Before running this sample, make sure you've correctly configured
  // the appropriate authentication methods in Firebase console. For more
  // info, see https://firebase.google.com/docs/auth/
  
  private var authStateDidChangeHandle: FIRAuthStateDidChangeListenerHandle?
  
  private(set) var auth: FIRAuth? = FIRAuth.auth()
  private(set) var authUI: FIRAuthUI? = FIRAuthUI.authUI()
  
  @IBOutlet private var signOutButton: UIButton!
  @IBOutlet private var startButton: UIButton!
  
  @IBOutlet private var signedInLabel: UILabel!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var emailLabel: UILabel!
  @IBOutlet private var uidLabel: UILabel!
  
  @IBOutlet var topConstraint: NSLayoutConstraint!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // If you haven't set up your authentications correctly these buttons
    // will still appear in the UI, but they'll crash the app when tapped.
    let providers: [FIRAuthProviderUI] = [
      FIRGoogleAuthUI(clientID: kGoogleAppClientID)!,
      FIRFacebookAuthUI(appID: kFacebookAppID)!,
    ]
    self.authUI?.signInProviders = providers
    
    // Strangely this is listed as TOSURL in the objc source and isn't
    // given a swift name that would otherwise make it import as termsOfServiceURL.
    self.authUI?.termsOfServiceURL = kFirebaseTermsOfService
    
    self.authStateDidChangeHandle =
      self.auth?.addAuthStateDidChangeListener(self.updateUI(auth:user:))
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if let handle = self.authStateDidChangeHandle {
      self.auth?.removeAuthStateDidChangeListener(handle)
    }
  }
  
  @IBAction func startPressed(sender: AnyObject) {
    // The function signature says it returns a view controller,
    // but when called it actually returns a closure returning a view controller.
    // Maybe this is a swift-objc interoperability bug.
    let controller = FIRAuthUI.authViewController(self.authUI!)() // wat?
    self.presentViewController(controller, animated: true, completion: nil)
  }
  
  @IBAction func signOutPressed(sender: AnyObject) {
    do {
     try self.auth?.signOut()
    } catch let error {
      // Again, fatalError is not a graceful way to handle errors.
      // This error is most likely a network error, so retrying here
      // makes sense.
      fatalError("Could not sign out: \(error)")
    }
  }
  
  // Boilerplate
  func updateUI(auth auth: FIRAuth, user: FIRUser?) {
    if let user = user {
      self.signOutButton.enabled = true
      self.startButton.enabled = false
      
      self.signedInLabel.text = "Signed in"
      self.nameLabel.text = "Name: " + (user.displayName ?? "(null)")
      self.emailLabel.text = "Email: " + (user.email ?? "(null)")
      self.uidLabel.text = "UID: " + user.uid
    } else {
      self.signOutButton.enabled = false
      self.startButton.enabled = true
      
      self.signedInLabel.text = "Not signed in"
      self.nameLabel.text = "Name"
      self.emailLabel.text = "Email"
      self.uidLabel.text = "UID"
    }
  }
  
  override func viewWillLayoutSubviews() {
    self.topConstraint.constant = self.topLayoutGuide.length
  }
  
  static func fromStoryboard(storyboard: UIStoryboard = AppDelegate.mainStoryboard) -> AuthViewController {
    return storyboard.instantiateViewControllerWithIdentifier("AuthViewController") as! AuthViewController
  }
}
