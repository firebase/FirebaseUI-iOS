//
//  Copyright (c) 2017 Google Inc.
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

/** @typedef FUIAccountSettingsCellAction
    @brief The type of block invoked when a cell is tapped.
 */
typedef void(^FUIAccountSettingsCellAction)(void);

@interface FUIAccountSettingsCell : UITableViewCell

/** @property title
    @brief The text of the @c titleLabel of the @c UITableViewCell.
 */
@property(nonatomic, copy, nullable) NSString *title;

/** @property value
    @brief The text of the @c detailTextLabel of the @c UITableViewCell.
 */
@property(nonatomic, copy, nullable) NSString *value;

/** @property action
 @brief The callback invoceked when cell is selected.
 */
@property(nonatomic, copy, nullable) FUIAccountSettingsCellAction action;

@end

NS_ASSUME_NONNULL_END
