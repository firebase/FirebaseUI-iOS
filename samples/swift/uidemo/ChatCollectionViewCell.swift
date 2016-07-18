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

class ChatCollectionViewCell: UICollectionViewCell {
  @IBOutlet private(set) var textLabel: UILabel! {
    didSet {
      textLabel.font = ChatCollectionViewCell.messageFont
    }
  }
  
  static func boundingRectForText(text: String, maxWidth: CGFloat) -> CGRect {
    let attributes = [NSFontAttributeName: ChatCollectionViewCell.messageFont]
    let rect = text.boundingRectWithSize(CGSize(width: maxWidth, height: CGFloat.max),
                                         options: [.UsesLineFragmentOrigin],
                                         attributes: attributes,
                                         context: nil)
    return rect
  }
  
  @IBOutlet var containerView: UIView! {
    didSet {
      containerView.layer.cornerRadius = 8
      containerView.layer.masksToBounds = true
    }
  }
  
  // These constraints are used to left- and right-align chat bubbles.
  @IBOutlet private(set) var leadingConstraint: NSLayoutConstraint! {
    didSet {
      leadingConstraint.identifier = "leading constraint"
    }
  }
  @IBOutlet private(set) var trailingConstraint: NSLayoutConstraint! {
    didSet {
      trailingConstraint.identifier = "trailing constraint"
    }
  }
  
  // This is the source of truth for the message font,
  // overriding whatever is set in interface builder.
  static var messageFont: UIFont {
    return UIFont.systemFontOfSize(UIFont.systemFontSize())
  }
  
  // Colors for messages sent by the client.
  static var selfColors: (background: UIColor, text: UIColor) {
    return (
      background: UIColor(red: 21 / 255, green: 60 / 255, blue: 235 / 255, alpha: 1),
      text: UIColor.whiteColor()
    )
  }
  
  // Colors for messages received by the client.
  static var othersColors: (background: UIColor, text: UIColor) {
    return (
      background: UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1),
      text: UIColor.blackColor()
    )
  }
}
