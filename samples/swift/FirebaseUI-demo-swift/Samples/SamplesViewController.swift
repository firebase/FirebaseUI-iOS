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

// This controller exists solely to list the samples we've defined thus far.
// Because all of that stuff is static and unchanging, if the app ever crashes
// in here it's probably a typo or some other small accident.
class SamplesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  fileprivate let reuseIdentifier = "SamplesViewControllerCell"
  
  @IBOutlet fileprivate var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    // self-sizing cells
    self.tableView.estimatedRowHeight = 85
    self.tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  // MARK: - UITableView Delegate
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let navController = self.navigationController! // assert nonnull
    let targetController = Sample(rawValue: (indexPath as NSIndexPath).row)!.controller()
    
    navController.pushViewController(targetController, animated: true)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  // MARK: - UITableView Data Source

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let sampleType = Sample(rawValue: (indexPath as NSIndexPath).row)!
    
    let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! SampleCell
    
    cell.configureWithType(sampleType)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Sample.total
  }
}
