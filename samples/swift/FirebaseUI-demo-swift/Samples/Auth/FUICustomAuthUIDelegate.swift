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

  func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
    switch error {
    case .some(let error as NSError) where UInt(error.code) == FUIAuthErrorCode.userCancelledSignIn.rawValue:
      print("User cancelled sign-in")
    case .some(let error as NSError) where error.userInfo[NSUnderlyingErrorKey] != nil:
      print("Login error: \(error.userInfo[NSUnderlyingErrorKey]!)")
    case .some(let error):
      print("Login error: \(error.localizedDescription)")
    case .none:
      return
    }
  }

  func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
    return FUICustomAuthPickerViewController(nibName: "FUICustomAuthPickerViewController",
                                             bundle: Bundle.main,
                                             authUI: authUI)
  }

  func emailEntryViewController(forAuthUI authUI: FUIAuth) -> FUIEmailEntryViewController {
    return FUICustomEmailEntryViewController(nibName: "FUICustomEmailEntryViewController",
                                             bundle: Bundle.main,
                                             authUI: authUI)
  }

  func passwordRecoveryViewController(forAuthUI authUI: FUIAuth, email: String) -> FUIPasswordRecoveryViewController {
    return FUICustomPasswordRecoveryViewController(nibName: "FUICustomPasswordRecoveryViewController",
                                                   bundle: Bundle.main,
                                                   authUI: authUI,
                                                   email: email)
  }

  func passwordSignInViewController(forAuthUI authUI: FUIAuth, email: String) -> FUIPasswordSignInViewController {
    return FUICustomPasswordSignInViewController(nibName: "FUICustomPasswordSignInViewController",
                                                 bundle: Bundle.main,
                                                 authUI: authUI,
                                                 email: email)
  }

  func passwordSignUpViewController(forAuthUI authUI: FUIAuth, email: String) -> FUIPasswordSignUpViewController {
    return FUICustomPasswordSignUpViewController(nibName: "FUICustomPasswordSignUpViewController",
                                                 bundle: Bundle.main,
                                                 authUI: authUI,
                                                 email: email)
  }

  func passwordVerificationViewController(forAuthUI authUI: FUIAuth, email: String, newCredential: AuthCredential) -> FUIPasswordVerificationViewController {
    return FUICustomPasswordVerificationViewController(nibName: "FUICustomPasswordVerificationViewController",
                                                       bundle: Bundle.main,
                                                       authUI: authUI,
                                                       email: email,
                                                       newCredential: newCredential)
  }
}
