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

#import <Foundation/Foundation.h>

@class FIRAuth;
@class FIRUser;
@class FUIAuth;
@class UIViewController;

NS_ASSUME_NONNULL_BEGIN

/** @protocol FUIAccountSettingsOperationUIDelegate
    @brief A delegate that provides UI methods for @c FUIAccountSettingsOperation.
 */
@protocol FUIAccountSettingsOperationUIDelegate <NSObject>

/** @property auth
    @brief The @c FIRAuth instance of the application.
 */
@property(nonatomic, strong, readonly) FIRAuth *auth;

/** @property authUI
    @brief The @c FUIAuth instance of the application.
 */
@property(nonatomic, strong, readonly) FUIAuth *authUI;

/** @fn incrementActivity
    @brief Increment the current activity count. If there's positive number of activities, display
        and animate the activity indicator with a short period of delay.
    @remarks Calls to @c incrementActivity and @c decrementActivity should be balanced.
 */
- (void)incrementActivity;

/** @fn decrementActivity
    @brief Decrement the current activity count. If the count reaches 0, stop and hide the
        activity indicator.
    @remarks Calls to @c incrementActivity and @c decrementActivity should be balanced.
 */
- (void)decrementActivity;

/** @fn presentBaseController
    @brief Called when initial Account Settings controller needs to be presented.
 */
- (void)presentBaseController;

/** @fn presentViewController:
    @brief Presents (pops) @c UIViewController from navigation stack.
 */
- (void)presentViewController:(UIViewController *)controller;

/** @fn pushViewController:
    @brief Adds (pushes) @c UIViewController to navigation stack.
 */
- (void)pushViewController:(UIViewController *)controller;

/** @fn presentingController
    @brief Provides access to presenting controller.
 */
- (UIViewController *)presentingController;

@end

/** @class FUIAccountSettingsOperation
    @brief Handles logic for every specific user operation.
 */
@interface FUIAccountSettingsOperation : NSObject

/** @fn executeOperationWithDelegate:showDialog:
    @brief Creates new instance of @c FUIAccountSettingsOperation and executes logic
        associated with it.
    @param delegate UI delegate which handles all UI related logic.
    @param showDialog Determines if operation specific UI should be started with confirmation
        dialog.
    @return Instance of the executed operation.
 */
+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                                  showDialog:(BOOL)showDialog;

/** @fn executeOperationWithDelegate:
    @brief Creates new instance of @c FUIAccountSettingsOperation and executes logic
        associated with it. New flow is started with new view.
    @param delegate UI delegate which handles all UI related logic.
    @return Instance of the executed operation.
 */
+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
