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

@objc(FUICustomEmailEntryViewController)

class FUICustomEmailEntryViewController: FUIEmailEntryViewController, UITextFieldDelegate {
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var nextButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    //override action of default 'Next' button to use custom layout elements'
    self.navigationItem.rightBarButtonItem?.target = self
    self.navigationItem.rightBarButtonItem?.action = #selector(onNextButton(_:))
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    //update state of all UI elements (e g disable 'Next' buttons)
    self.updateEmailValue(emailTextField)
  }

  @IBAction func onBack(_ sender: AnyObject) {
    self.onBack()
  }
  @IBAction func onNextButton(_ sender: AnyObject) {
    if let email = emailTextField.text {
      self.onNext(email)
    }
  }
  @IBAction func onCancel(_ sender: AnyObject) {
    self.cancelAuthorization()
  }

  @IBAction func onViewSelected(_ sender: AnyObject) {
    emailTextField.resignFirstResponder()
  }

  @IBAction func updateEmailValue(_ sender: UITextField) {
    if emailTextField == sender, let email = emailTextField.text {
      nextButton.isEnabled = !email.isEmpty
      self.didChangeEmail(email)
    }
  }

// MARK: - UITextFieldDelegate methods

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField, let email = textField.text {
      self.onNext(email)
    }

    return false
  }

}
