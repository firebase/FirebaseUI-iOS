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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  static var mainStoryboard: UIStoryboard {
    return UIStoryboard(name: "Main", bundle: nil)
  }

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Successfully running this sample requires an app in Firebase and an
    // accompanying valid GoogleService-Info.plist file.
    FIRApp.configure()
    return true
  }
  
  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    let sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String?
    // Seems like an oversight that this API doesn't take a nullable sourceApplication.
    if FIRAuthUI.authUI()?.handleOpenURL(url, sourceApplication: sourceApplication!) ?? false {
      return true
    }
    // other URL handling goes here.
    return false
  }
}

