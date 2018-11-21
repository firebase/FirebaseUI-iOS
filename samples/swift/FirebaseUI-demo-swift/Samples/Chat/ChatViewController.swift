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
import FirebaseUI

/// View controller demonstrating using a FUICollectionViewDataSource
/// to populate a collection view with chat messages. The relevant code
/// is in the call to `collectionViewDataSource.populateCellWithBlock`.
class ChatViewController: UIViewController, UICollectionViewDelegateFlowLayout {
  // All of the error handling in this controller is done with `fatalError`;
  // please don't copy paste it into your production code.

  fileprivate static let reuseIdentifier = "ChatCollectionViewCell"

  @IBOutlet fileprivate var collectionView: UICollectionView!
  @IBOutlet fileprivate var textView: UITextView! {
    didSet {
      textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
      textView.layer.borderWidth = 1
      textView.layer.cornerRadius = 8
      textView.layer.masksToBounds = true
    }
  }
  @IBOutlet fileprivate var sendButton: UIButton!

  /// Used to shift view contents up when the keyboard appears.
  @IBOutlet fileprivate var bottomConstraint: NSLayoutConstraint!

  fileprivate let auth = Auth.auth()
  fileprivate let chatReference = Database.database().reference().child("swift_demo-chat")

  fileprivate var collectionViewDataSource: FUICollectionViewDataSource!

  fileprivate var user: User?
  fileprivate var query: DatabaseQuery?

  fileprivate var authStateListenerHandle: AuthStateDidChangeListenerHandle?

  // MARK: - Interesting stuff

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.authStateListenerHandle = self.auth.addStateDidChangeListener { (auth, user) in
      self.user = user
      self.query = self.chatReference.queryLimited(toLast: 50)

      self.collectionViewDataSource =
          self.collectionView.bind(to: self.query!) { (view, indexPath, snap) -> UICollectionViewCell in
            let cell = view.dequeueReusableCell(withReuseIdentifier: ChatViewController.reuseIdentifier,
                                                for: indexPath) as! ChatCollectionViewCell
            let chat = Chat(snapshot: snap)!
            cell.populateCellWithChat(chat, user: self.user, maxWidth: self.view.frame.size.width)
            return cell
      }

      // FUIArray has a delegate method `childAdded` that could be used here,
      // but unfortunately FirebaseCollectionViewDataSource uses the FUICollection
      // delegate methods to update its own internal state, so in order to scroll
      // on new insertions we still need to use the query directly.
      self.query!.observe(.childAdded, with: { [unowned self] _ in
        self.scrollToBottom(animated: true)
      })
    }

    self.auth.signInAnonymously { (user, error) in
      if let error = error {
        // An error here means the user couldn't sign in. Correctly
        // handling it depends on the context as well as your app's
        // capabilities, but this is usually a good place to
        // present "retry" and "forgot your password?" screens.
        fatalError("Sign in failed: \(error.localizedDescription)")
      }
    }

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

  @objc fileprivate func didTapSend(_ sender: AnyObject) {
    guard let user = self.auth.currentUser else { return }
    let uid = user.uid
    let name = "User " + uid[uid.characters.startIndex..<uid.characters.index(uid.characters.startIndex, offsetBy: 6)]
    let _text = self.textView.text as String?
    guard let text = _text else { return }
    if (text.isEmpty) { return }

    let chat = Chat(uid: uid, name: name, text: text)

    self.chatReference.childByAutoId().setValue(chat.dictionary) { (error, dbref) in
      if let error = error {
        // An error here most likely means the user doesn't have permission
        // to chat (not signed in?) or the user has no internet connection.
        fatalError("Failed to write message: \(error.localizedDescription)")
      }
    }

    self.textView.text = ""
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.collectionView.backgroundColor = UIColor.white
    self.collectionView.delegate = self
    let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    layout.minimumInteritemSpacing = CGFloat.greatestFiniteMagnitude
    layout.minimumLineSpacing = 4

    self.sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let handle = self.authStateListenerHandle {
      self.auth.removeStateDidChangeListener(handle)
    }
    NotificationCenter.default.removeObserver(self)
  }

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
    self.bottomConstraint.constant = 6

    let userInfo = (notification as NSNotification).userInfo!
    let curve = UIViewAnimationCurve(rawValue: userInfo[UIKeyboardAnimationCurveUserInfoKey] as! Int)!
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double

    UIView.setAnimationCurve(curve)
    UIView.animate(withDuration: duration, animations: {
      self.view.layoutIfNeeded()
    })
  }

  fileprivate func scrollToBottom(animated: Bool) {
    let count = Int(self.collectionViewDataSource.count)
    guard count > 0 else { return }
    let indexPath = IndexPath(item: count - 1, section: 0)
    self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
  }

  // MARK: UICollectionViewDelegateFlowLayout

  func collectionView(_ collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let heightPadding: CGFloat = 16

    let width = self.view.frame.size.width
    let blob = self.collectionViewDataSource.snapshot(at: indexPath.item)
    let text = Chat(snapshot: blob)!.text

    let rect = ChatCollectionViewCell.boundingRectForText(text, maxWidth: width)

    let height = CGFloat(ceil(Double(rect.size.height))) + heightPadding
    return CGSize(width: width, height: height)
  }
}

struct Chat {
  var uid: String
  var name: String
  var text: String

  var dictionary: [String: String] {
    return [
      "uid" : self.uid,
      "name": self.name,
      "text": self.text,
    ]
  }

  init(uid: String, name: String, text: String) {
    self.name = name; self.uid = uid; self.text = text
  }

  init?(snapshot: DataSnapshot) {
    guard let dict = snapshot.value as? [String: String] else { return nil }
    guard let name = dict["name"] else { return nil }
    guard let uid  = dict["uid"]  else { return nil }
    guard let text = dict["text"] else { return nil }

    self.name = name
    self.uid = uid
    self.text = text
  }
}
