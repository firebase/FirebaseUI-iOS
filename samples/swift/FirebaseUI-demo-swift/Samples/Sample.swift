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
// is used by the SamplesViewController to layout all of the samples
// and display basic information about them.
enum Sample: Int, RawRepresentable {
  
  // When adding new samples, add a new value here and fill
  // out the switch statements below as necessary.
  case chat = 0
  case storage = 1

  static var total: Int {
    var count = 0
    while let _ = Sample(rawValue: count) {
      count += 1
    }
    return count
  }
  
  var labels: (title: String, subtitle: String) {
    switch self {
    case .chat:
      return (
        title: "Chat",
        subtitle: "Demonstrates using a FUICollectionViewDataSource to load data from Firebase Database into a UICollectionView for a basic chat app."
      )
    case .storage:
      return (
        title: "Storage",
        subtitle: "Demonstrates using FirebaseStorageUI to populate an image view."
      )
    }
  }
  
  @MainActor func controller() -> UIViewController {
    switch self {
    case .chat:
      return UIStoryboard.instantiateViewController("Main", identifier: "ChatViewController")
    case .storage:
      return UIStoryboard.instantiateViewController("Main", identifier: "StorageViewController")
    }
  }
}
