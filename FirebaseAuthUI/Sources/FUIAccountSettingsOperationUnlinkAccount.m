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

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperationUnlinkAccount.h"

#import "FirebaseAuthUI/Sources/FUIAccountSettingsOperation_Internal.h"
#import "FirebaseAuthUI/Sources/Public/FirebaseAuthUI/FUIAuthBaseViewController_Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUIAccountSettingsOperationUnlinkAccount ()
{
  id<FIRUserInfo> _provider;
}
@end 

@implementation FUIAccountSettingsOperationUnlinkAccount

+ (instancetype)executeOperationWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                                  showDialog:(BOOL)showDialog
                                    provider:(id<FIRUserInfo>)provider {
  FUIAccountSettingsOperationUnlinkAccount *operation =
      [[self alloc] initWithDelegate:delegate provider:provider];
  [operation execute:showDialog];
  return operation;
}

- (instancetype)initWithDelegate:(id<FUIAccountSettingsOperationUIDelegate>)delegate
                        provider:(id<FIRUserInfo>) provider {
  if (self = [super initWithDelegate:delegate]) {
    _provider = provider;
  }
  return self;
}

- (FUIAccountSettingsOperationType)operationType {
  return FUIAccountSettingsOperationTypeUnlinkAccount;
}

- (void)execute:(BOOL)showDialog {
  __block FUIStaticContentTableViewCell *cell =
      [FUIStaticContentTableViewCell cellWithTitle:
          [FUIAuthBaseViewController providerLocalizedName:_provider.providerID]
                                             value:_provider.displayName
                                              type:FUIStaticContentTableViewCellTypeDefault
                                            action:nil];
  FUIStaticContentTableViewContent *contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                   cells:@[cell]],
    ]];

  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:contents
                                                          nextTitle:
          FUILocalizedString(kStr_UnlinkAction)
                                                       nextAction:^{
        [self showUnlinkConfirmationDialog];
      }];
  controller.title = FUILocalizedString(kStr_UnlinkTitle);
  [self.delegate pushViewController:controller];
}

- (void)showUnlinkConfirmationDialog {
  UIAlertController *alertController =
      [UIAlertController alertControllerWithTitle:FUILocalizedString(kStr_UnlinkConfirmationTitle)
                                          message:FUILocalizedString(kStr_UnlinkConfirmationMessage)
                                   preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *action =
      [UIAlertAction actionWithTitle:FUILocalizedString(kStr_UnlinkConfirmationActionTitle)
                               style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction *_Nonnull action) { [self unlinkAcount]; }];
  [alertController addAction:action];
  UIAlertAction *cancelAction =
  [UIAlertAction actionWithTitle:FUILocalizedString(kStr_Cancel)
                           style:UIAlertActionStyleCancel
                         handler:nil];
  [alertController addAction:cancelAction];
  [self.delegate presentViewController:alertController];
}

- (void)unlinkAcount {
  [self.delegate.auth.currentUser unlinkFromProvider:_provider.providerID
                                          completion:^(FIRUser *_Nullable user,
                                                       NSError *_Nullable error) {
    [self finishOperationWithError:error];
    [self.delegate presentBaseController];
  }];
}

@end

NS_ASSUME_NONNULL_END
