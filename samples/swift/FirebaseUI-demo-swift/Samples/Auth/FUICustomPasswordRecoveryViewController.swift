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
import FirebaseUI

@objc(FUICustomPasswordRecoveryViewController)

class FUICustomPasswordRecoveryViewController: FUIPasswordRecoveryViewController, UITextFieldDelegate {
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var recoverButton: UIBarButtonItem!

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, authUI: FUIAuth, email: String?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil, authUI: authUI, email: email)

    emailTextField.text = email
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    //override action of default 'Next' button to use custom layout elements'
    self.navigationItem.rightBarButtonItem?.target = self
    self.navigationItem.rightBarButtonItem?.action = #selector(onRecover(_:))
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    //update state of all UI elements (e g disable 'Next' buttons)
    self.updateEmailValue(emailTextField)
  }

  @IBAction func onBack(_ sender: AnyObject) {
    self.onBack()
  }

  @IBAction func onRecover(_ sender: AnyObject) {
    if let email = emailTextField.text {
      self.recoverEmail(email)
    }
  }
  @IBAction func onCancel(_ sender: AnyObject) {
    self.cancelAuthorization()
  }

  @IBAction func updateEmailValue(_ sender: UITextField) {
    if emailTextField == sender, let email = emailTextField.text {
      recoverButton.isEnabled = !email.isEmpty
      self.didChangeEmail(email)
    }
  }

  @IBAction func onViewSelected(_ sender: AnyObject) {
    emailTextField.resignFirstResponder()
  }

  // MARK: - UITextFieldDelegate methods

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField, let email = textField.text {
      self.recoverEmail(email)
    }

    return false
  }
}
