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

#import "FUIAccountSettingsOperation.h"

@protocol FIRUserInfo;

NS_ASSUME_NONNULL_BEGIN

/** @class FUIAccountSettingsOperationUnlinkAccount
    @brief Handles logic of unlinking from 3P provider operation.
 */
@interface FUIAccountSettingsOperationUnlinkAccount : FUIAccountSettingsOperation

/** @fn executeOperationWithDelegate:showDialog:
    @brief Instead use @c executeOperationWithDelegate:showDialog:provider:
    @param delegate UI delegate which handles all UI related logic.
    @param showDialog Determines if operation specific UI should be started with confirmation
        dialog.
    @return Instance of the executed operation.
 */
+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                                  showDialog:(BOOL)showDialog NS_UNAVAILABLE;

/** @fn executeOperationWithDelegate:
    @brief Instead use @c executeOperationWithDelegate:showDialog:provider:
    @param delegate UI delegate which handles all UI related logic.
    @return Instance of the executed operation.
 */
+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
    NS_UNAVAILABLE;

/** @fn executeOperationWithDelegate:showDialog:provider:
    @brief Creates new instance of @c FUIAccountSettingsOperationUnlinkAccount and executes logic
        associated with it.
    @param delegate UI delegate which handles all UI related logic.
    @param showDialog Determines if operation specific UI should be started with confirmation
        dialog.
    @param provider Instance of 3P provider retrieved from currently logged in @c FIRUser.
    @return Instance of the executed operation.
 */
+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                                  showDialog:(BOOL)showDialog
                                    provider:(id<FIRUserInfo>)provider;

@end

NS_ASSUME_NONNULL_END
