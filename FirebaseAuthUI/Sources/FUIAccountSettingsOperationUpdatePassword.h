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

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperation.h"

NS_ASSUME_NONNULL_BEGIN

/** @class FUIAccountSettingsOperationUpdatePassword
    @brief Handles logic of updating password operation.
 */
@interface FUIAccountSettingsOperationUpdatePassword : FUIAccountSettingsOperation

/** @fn executeOperationWithDelegate:showDialog:
    @brief Instead use @c executeOperationWithDelegate:showDialog:newPassword:
    @param delegate UI delegate which handles all UI related logic.
    @param showDialog Determines if operation specific UI should be started with confirmation
        dialog.
    @return Instance of the executed operation.
 */
+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                                  showDialog:(BOOL)showDialog NS_UNAVAILABLE;

/** @fn executeOperationWithDelegate:
    @brief Instead use @c executeOperationWithDelegate:showDialog:newPassword:
    @param delegate UI delegate which handles all UI related logic.
    @return Instance of the executed operation.
 */
+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
    NS_UNAVAILABLE;

/** @fn executeOperationWithDelegate:showDialog:newPassword:
    @brief Creates new instance of @c FUIAccountSettingsOperationUnlinkAccount and executes logic
        associated with it.
    @param delegate UI delegate which handles all UI related logic.
    @param showDialog Determines if operation specific UI should be started with confirmation
        dialog.
    @param newPassword Defines if this is add password (pass YES) or update password operation.
    @return Instance of the executed operation.
 */
+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                                  showDialog:(BOOL)showDialog
                                 newPassword:(BOOL)newPassword;

@end

NS_ASSUME_NONNULL_END
