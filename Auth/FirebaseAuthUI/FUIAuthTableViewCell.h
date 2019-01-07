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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** @class FUIAuthTableViewCell
    @brief A common table view cell that can be used in multiple view controllers.
 */
@interface FUIAuthTableViewCell : UITableViewCell

/** @property label
    @brief The label that describes the purpose of @c textField.
 */
@property(nonatomic, strong) IBOutlet UILabel *label;

/** @property textField
    @brief The text field that collects user's input.
 */
@property(nonatomic, strong) IBOutlet UITextField *textField;

@end

NS_ASSUME_NONNULL_END
