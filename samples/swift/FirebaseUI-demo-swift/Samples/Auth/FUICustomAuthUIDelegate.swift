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
import FirebaseAuthUI
import FirebaseAuth

class FUICustomAuthDelegate: NSObject, FUIAuthDelegate {

  func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
    guard let authError = error else { return }

    let errorCode = UInt((authError as NSError).code)

    switch errorCode {
    case FUIAuthErrorCode.userCancelledSignIn.rawValue:
      print("User cancelled sign-in");
      break
    default:
      let detailedError = (authError as NSError).userInfo[NSUnderlyingErrorKey] ?? authError
      print("Login error: \((detailedError as! NSError).localizedDescription)");
    }
  }

  func authPickerViewController(for authUI: FUIAuth) -> FUIAuthPickerViewController {
    return FUICustomAuthPickerViewController(authUI: authUI)
  }

  func emailEntryViewController(for authUI: FUIAuth) -> FUIEmailEntryViewController {
    return FUICustomEmailEntryViewController(authUI: authUI)
  }

  func passwordRecoveryViewController(for authUI: FUIAuth, email: String) -> FUIPasswordRecoveryViewController {
    return FUICustomPasswordRecoveryViewController(authUI: authUI, email: email)
  }

  func passwordSignInViewController(for authUI: FUIAuth, email: String) -> FUIPasswordSignInViewController {
    return FUICustomPasswordSignInViewController(authUI: authUI, email: email)
  }

  func passwordSignUpViewController(for authUI: FUIAuth, email: String) -> FUIPasswordSignUpViewController {
    return FUICustomPasswordSignUpViewController(authUI: authUI, email: email)
  }

  func passwordVerificationViewController(for authUI: FUIAuth, email: String, newCredential: FIRAuthCredential) -> FUIPasswordVerificationViewController {
    return FUICustomPasswordVerificationViewController(authUI: authUI, email: email, newCredential: newCredential)
  }
}
