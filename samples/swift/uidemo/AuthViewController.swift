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

class AuthViewController: UIViewController {
  
  private(set) var auth: FIRAuth? = nil
  
  @IBOutlet var signInButton: UIButton!
  @IBOutlet var signOutButton: UIButton!
  
  
  
  static func fromStoryboard(storyboard: UIStoryboard = AppDelegate.mainStoryboard) -> AuthViewController {
    return storyboard.instantiateViewControllerWithIdentifier("AuthViewController") as! AuthViewController
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.auth = FIRAuth.auth()
    if let user = self.auth?.currentUser {
      print("logged in! \(user.displayName ?? "<empty>")")
    }
  }
}
