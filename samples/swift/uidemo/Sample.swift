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

// As we add more sample use cases to FirebaseUI, 
// this enum will eventually grow into a catalogue
// of features.
enum Sample: Int, RawRepresentable {
  
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
      return ChatViewController.fromStoryboard()
    case .Auth:
      return AuthViewController.fromStoryboard()
    }
  }
}
