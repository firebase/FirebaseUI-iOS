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
class FIRSamplesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  private let reuseIdentifier = "FIRSamplesViewControllerCell"
  
  @IBOutlet private var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    // self-sizing cells
    self.tableView.estimatedRowHeight = 85
    self.tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  // MARK: - UITableView Delegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let navController = self.navigationController! // assert nonnull
    let targetController = FIRSample(rawValue: indexPath.row)!.controller()
    
    navController.pushViewController(targetController, animated: true)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  // MARK: - UITableView Data Source

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let sampleType = FIRSample(rawValue: indexPath.row)!
    
    let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! FIRSampleCell
    
    cell.configureWithType(sampleType)
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return FIRSample.total
  }
}
