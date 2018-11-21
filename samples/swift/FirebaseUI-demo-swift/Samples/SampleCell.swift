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

class SampleCell: UITableViewCell {
  
  @IBOutlet fileprivate var titleLabel: UILabel!
  @IBOutlet fileprivate var subtitleLabel: UILabel!
  
  override convenience init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    self.init(reuseIdentifier: reuseIdentifier!)
  }
  
  init(reuseIdentifier: String) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
  }
  
  convenience init(type: Sample, reuseIdentifier: String) {
    self.init(reuseIdentifier: reuseIdentifier)
    
    self.configureWithType(type)
  }
  
  func configureWithType(_ type: Sample) {
    let labels = type.labels
    self.titleLabel.text = labels.title
    self.subtitleLabel.text = labels.subtitle
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
