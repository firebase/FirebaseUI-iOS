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

import FirebaseStorageUI

class FIRStorageViewController: UIViewController {

  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var textField: UITextField!

  private var storageRef = FIRStorage.storage().reference()

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.textField.autocorrectionType = .No
    self.textField.autocapitalizationType = .None
    self.imageView.contentMode = .ScaleAspectFit

    // Notification boilerplate to handle keyboard appearance/disappearance
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(keyboardWillShow),
                                                     name: UIKeyboardWillShowNotification,
                                                     object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(keyboardWillHide),
                                                     name: UIKeyboardWillHideNotification,
                                                     object: nil)
  }

  @IBAction private func loadButtonPressed(sender: AnyObject) {
    self.imageView.image = nil
    guard let text = self.textField.text else { return }
    guard let url = NSURL(string: text) else { return }

    self.storageRef = FIRStorage.storage().referenceWithPath(url.path ?? "")

    self.imageView.sd_setImageWithStorageReference(self.storageRef,
      placeholderImage: nil) { (image, error, cacheType, storageRef) in
      if let error = error {
        print("Error loading image: \(error)")
      }
    }
  }

  // MARK: Keyboard boilerplate

  /// Used to shift textfield up when the keyboard appears.
  @IBOutlet private var bottomConstraint: NSLayoutConstraint!

  @objc private func keyboardWillShow(notification: NSNotification) {
    let userInfo = notification.userInfo!
    let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
    let endHeight = endFrameValue.CGRectValue().size.height

    self.bottomConstraint.constant = endHeight

    let curve = UIViewAnimationCurve(rawValue: userInfo[UIKeyboardAnimationCurveUserInfoKey] as! Int)!
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double

    UIView.setAnimationCurve(curve)
    UIView.animateWithDuration(duration) {
      self.view.layoutIfNeeded()
    }
  }

  @objc private func keyboardWillHide(notification: NSNotification) {
    self.bottomConstraint.constant = 0

    let userInfo = notification.userInfo!
    let curve = UIViewAnimationCurve(rawValue: userInfo[UIKeyboardAnimationCurveUserInfoKey] as! Int)!
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double

    UIView.setAnimationCurve(curve)
    UIView.animateWithDuration(duration) {
      self.view.layoutIfNeeded()
    }
  }
}
