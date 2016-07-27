//
//  AuthViewController.swift
//  uidemo
//
//  Created by Morgan Chen on 7/27/16.
//  Copyright © 2016 morganchen. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {
  static func fromStoryboard(storyboard: UIStoryboard = AppDelegate.mainStoryboard) -> AuthViewController {
    return storyboard.instantiateViewControllerWithIdentifier("AuthViewController") as! AuthViewController
  }
}
