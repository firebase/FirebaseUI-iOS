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
import FirebaseTwitterAuthUI

let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")!

/// A view controller displaying a basic sign-in flow using FIRAuthUI.
class FIRAuthViewController: UITableViewController {
  // Before running this sample, make sure you've correctly configured
  // the appropriate authentication methods in Firebase console. For more
  // info, see the Auth README at ../../FirebaseAuthUI/README.md
  // and https://firebase.google.com/docs/auth/

  fileprivate var authStateDidChangeHandle: FIRAuthStateDidChangeListenerHandle?

  fileprivate(set) var auth: FIRAuth? = FIRAuth.auth()
  fileprivate(set) var authUI: FIRAuthUI? = FIRAuthUI.default()

  @IBOutlet weak var cellSignedIn: UITableViewCell!
  @IBOutlet weak var cellName: UITableViewCell!
  @IBOutlet weak var cellEmail: UITableViewCell!
  @IBOutlet weak var cellUid: UITableViewCell!
  @IBOutlet weak var cellAccessToken: UITableViewCell!
  @IBOutlet weak var cellIdToken: UITableViewCell!

  @IBOutlet weak var btnAuthorization: UIBarButtonItem!


  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 240;

    // If you haven't set up your authentications correctly these buttons
    // will still appear in the UI, but they'll crash the app when tapped.
    let providers: [FIRAuthProviderUI] = [
      FIRGoogleAuthUI(),
      FIRFacebookAuthUI(),
      FIRTwitterAuthUI(),
    ]
    self.authUI?.providers = providers

    self.authUI?.tosurl = kFirebaseTermsOfService

    self.authStateDidChangeHandle =
      self.auth?.addStateDidChangeListener(self.updateUI(auth:user:))
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let handle = self.authStateDidChangeHandle {
      self.auth?.removeStateDidChangeListener(handle)
    }
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  @IBAction func onAuthorize(_ sender: AnyObject) {
    if (self.auth?.currentUser) != nil {
      do {
        try self.authUI?.signOut()
      } catch let error {
        // Again, fatalError is not a graceful way to handle errors.
        // This error is most likely a network error, so retrying here
        // makes sense.
        fatalError("Could not sign out: \(error)")
      }

    } else {
      let controller = self.authUI!.authViewController()
      self.present(controller, animated: true, completion: nil)
    }
  }

  // Boilerplate
  func updateUI(auth: FIRAuth, user: FIRUser?) {
    if let user = self.auth?.currentUser {
      self.cellSignedIn.textLabel?.text = "Signed in"
      self.cellName.textLabel?.text = user.displayName ?? "(null)"
      self.cellEmail.textLabel?.text = user.email ?? "(null)"
      self.cellUid.textLabel?.text = user.uid

      self.btnAuthorization.title = "Sign Out";
    } else {
      self.cellSignedIn.textLabel?.text = "Not signed in"
      self.cellName.textLabel?.text = "null"
      self.cellEmail.textLabel?.text = "null"
      self.cellUid.textLabel?.text = "null"

      self.btnAuthorization.title = "Sign In";
    }

    self.cellAccessToken.textLabel?.text = getAllAccessTokens()
    self.cellIdToken.textLabel?.text = getAllIdTokens()

    self.tableView.reloadData()
  }

  func getAllAccessTokens() -> String {
    var result = ""
    for provider in self.authUI!.providers {
      result += (provider.shortName + ": " + provider.accessToken + "\n")
    }

    return result
  }

  func getAllIdTokens() -> String {
    var result = ""
    for provider in self.authUI!.providers {
      result += (provider.shortName + ": " + (provider.idToken ?? "null")  + "\n")
    }

    return result
  }
}
