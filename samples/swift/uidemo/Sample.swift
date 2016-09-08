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

// This enum represents the samples that this app knows about, and
// is used by the MenuViewController to layout all of the samples
// and display basic information about them.
enum Sample: Int, RawRepresentable {
  
  // When adding new samples, add a new value here and fill
  // out the switch statements below as necessary.
  case Chat = 0
  case Auth = 1
  
  static var total: Int {
    var count = 0
    while let _ = Sample(rawValue: count) {
      count += 1
    }
    return count
  }
  
  var labels: (title: String, subtitle: String) {
    switch self {
    case .Chat:
      return (
        title: "Chat",
        subtitle: "Demonstrates using a FirebaseCollectionViewDataSource to load data from Firebase Database into a UICollectionView for a basic chat app."
      )
    case .Auth:
      return (
        title: "Auth",
        subtitle: "Demonstrates the FirebaseAuthUI flow with customization options"
      )
    }
  }
  
  func controller() -> UIViewController {
    switch self {
    case .Chat:
      return UIStoryboard.instantiateViewController("Main", identifier: "ChatViewController") as! ChatViewController
    case .Auth:
      return UIStoryboard.instantiateViewController("Main", identifier: "AuthViewController") as! AuthViewController
    }
  }
}
