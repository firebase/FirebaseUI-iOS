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

class StorageViewController: UIViewController {

  @IBOutlet fileprivate var imageView: UIImageView!
  @IBOutlet fileprivate var textField: UITextField!

  fileprivate var storageRef = Storage.storage().reference()

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.textField.autocorrectionType = .no
    self.textField.autocapitalizationType = .none
    self.imageView.contentMode = .scaleAspectFit

    // Notification boilerplate to handle keyboard appearance/disappearance
    NotificationCenter.default.addObserver(self,
                                                     selector: #selector(keyboardWillShow),
                                                     name: NSNotification.Name.UIKeyboardWillShow,
                                                     object: nil)
    NotificationCenter.default.addObserver(self,
                                                     selector: #selector(keyboardWillHide),
                                                     name: NSNotification.Name.UIKeyboardWillHide,
                                                     object: nil)
  }

  @IBAction fileprivate func loadButtonPressed(_ sender: AnyObject) {
    self.imageView.image = nil
    guard let text = self.textField.text else { return }
    guard let url = URL(string: text) else { return }

    self.storageRef = Storage.storage().reference(withPath: url.path)

    self.imageView.sd_setImage(with: self.storageRef,
      placeholderImage: nil) { (image, error, cacheType, storageRef) in
      if let error = error {
        print("Error loading image: \(error)")
      }
    }
  }

  // MARK: Keyboard boilerplate

  /// Used to shift textfield up when the keyboard appears.
  @IBOutlet fileprivate var bottomConstraint: NSLayoutConstraint!

  @objc fileprivate func keyboardWillShow(_ notification: Notification) {
    let userInfo = (notification as NSNotification).userInfo!
    let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
    let endHeight = endFrameValue.cgRectValue.size.height

    self.bottomConstraint.constant = endHeight

    let curve = UIViewAnimationCurve(rawValue: userInfo[UIKeyboardAnimationCurveUserInfoKey] as! Int)!
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double

    UIView.setAnimationCurve(curve)
    UIView.animate(withDuration: duration, animations: {
      self.view.layoutIfNeeded()
    }) 
  }

  @objc fileprivate func keyboardWillHide(_ notification: Notification) {
    self.bottomConstraint.constant = 0

    let userInfo = (notification as NSNotification).userInfo!
    let curve = UIViewAnimationCurve(rawValue: userInfo[UIKeyboardAnimationCurveUserInfoKey] as! Int)!
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double

    UIView.setAnimationCurve(curve)
    UIView.animate(withDuration: duration, animations: {
      self.view.layoutIfNeeded()
    }) 
  }
}
