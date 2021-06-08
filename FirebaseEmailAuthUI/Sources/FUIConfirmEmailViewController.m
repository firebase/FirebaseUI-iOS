//
//  Copyright (c) 2018 Google Inc.
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

#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIConfirmEmailViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>

#import <FirebaseAuthUI/FirebaseAuthUI.h>

#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIEmailAuth.h"
#import "FirebaseEmailAuthUI/Sources/FUIEmailAuth_Internal.h"
#import "FirebaseEmailAuthUI/Sources/FUIEmailAuthStrings.h"
#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIPasswordSignInViewController.h"
#import "FirebaseEmailAuthUI/Sources/Public/FirebaseEmailAuthUI/FUIPasswordSignUpViewController.h"

/** @var kCellReuseIdentifier
    @brief The reuse identifier for table view cell.
 */
static NSString *const kCellReuseIdentifier = @"cellReuseIdentifier";

/** @var kAppIDCodingKey
    @brief The key used to encode the app ID for NSCoding.
 */
static NSString *const kAppIDCodingKey = @"appID";

/** @var kAuthUICodingKey
    @brief The key used to encode @c FUIAuth instance for NSCoding.
 */
static NSString *const kAuthUICodingKey = @"authUI";

/** @var kEmailCellAccessibilityID
    @brief The Accessibility Identifier for the @c email sign in cell.
 */
static NSString *const kEmailCellAccessibilityID = @"EmailCellAccessibilityID";

/** @var kNextButtonAccessibilityID
    @brief The Accessibility Identifier for the @c next button.
 */
static NSString *const kNextButtonAccessibilityID = @"NextButtonAccessibilityID";

@interface FUIConfirmEmailViewController () <UITableViewDataSource, UITextFieldDelegate>

/** @property emailField
    @brief The @c UITextField that user enters email address into.
 */
@property (nonatomic) UITextField *emailField;

/** @property tableView
    @brief The @c UITableView used to store all UI elements.
 */
@property (nonatomic, weak) IBOutlet UITableView *tableView;

/** @property termsOfServiceView
    @brief The @c Text view which displays Terms of Service.
 */
@property (nonatomic, weak) IBOutlet FUIPrivacyAndTermsOfServiceView *termsOfServiceView;

@end

@implementation FUIConfirmEmailViewController

- (instancetype)initWithAuthUI:(FUIAuth *)authUI {
  return [self initWithNibName:NSStringFromClass([self class])
                        bundle:[FUIEmailAuth bundle]
                        authUI:authUI];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                         authUI:(FUIAuth *)authUI {
  self = [super initWithNibName:nibNameOrNil
                         bundle:nibBundleOrNil
                         authUI:authUI];
  if (self) {
    self.title = FUILocalizedString(kStr_ConfirmEmail);
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *nextButtonItem =
      [FUIAuthBaseViewController barItemWithTitle:FUILocalizedString(kStr_Next)
                                           target:self
                                           action:@selector(next)];
  nextButtonItem.accessibilityIdentifier = kNextButtonAccessibilityID;
  self.navigationItem.rightBarButtonItem = nextButtonItem;
  self.termsOfServiceView.authUI = self.authUI;
  [self.termsOfServiceView useFullMessage];

  [self enableDynamicCellHeightForTableView:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (self.navigationController.viewControllers.firstObject == self) {
    if (!self.authUI.shouldHideCancelButton) {
      UIBarButtonItem *cancelBarButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                    target:self
                                                    action:@selector(cancelAuthorization)];
      self.navigationItem.leftBarButtonItem = cancelBarButton;
    }
    self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:FUILocalizedString(kStr_Back)
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];

    if (@available(iOS 13, *)) {
      if (!self.authUI.isInteractiveDismissEnabled) {
        self.modalInPresentation = YES;
      }
    }
  }
}

#pragma mark - Actions

- (void)next {
  [self onNext:self.emailField.text];
}

- (void)onNext:(NSString *)emailText {
  FUIEmailAuth *emailAuth = [self.authUI providerWithID:FIREmailAuthProviderID];

  if (![[self class] isValidEmail:emailText]) {
    [self showAlertWithMessage:FUILocalizedString(kStr_InvalidEmailError)];
    return;
  }

  [self incrementActivity];
  FIRAuthCredential *credential =
      [FIREmailAuthProvider credentialWithEmail:emailText link:emailAuth.emailLink];

  void (^completeSignInBlock)(FIRAuthDataResult *, NSError *) = ^(FIRAuthDataResult *authResult,
                                                                  NSError *error) {
    [self decrementActivity];

    if (error) {
      switch (error.code) {
        case FIRAuthErrorCodeWrongPassword:
          [self showAlertWithMessage:FUILocalizedString(kStr_WrongPasswordError)];
          return;
        case FIRAuthErrorCodeUserNotFound:
          [self showAlertWithMessage:FUILocalizedString(kStr_UserNotFoundError)];
          return;
        case FIRAuthErrorCodeUserDisabled:
          [self showAlertWithMessage:FUILocalizedString(kStr_AccountDisabledError)];
          return;
        case FIRAuthErrorCodeTooManyRequests:
          [self showAlertWithMessage:FUILocalizedString(kStr_SignInTooManyTimesError)];
          return;
        default:
          [self showAlertWithMessage:error.description];
          return;
      }
    }

    [[self class] showAlertWithTitle:FUILocalizedString(kStr_SignedIn)
                             message:nil
                         actionTitle:nil
                       actionHandler:nil
                        dismissTitle:@"OK"
                      dismissHandler:^{
                        [self.navigationController dismissViewControllerAnimated:YES completion:^{
                          [self.authUI invokeResultCallbackWithAuthDataResult:authResult URL:nil error:error];
                        }];
                      }
            presentingViewController:self];
  };

  [self.auth signInWithCredential:credential completion:completeSignInBlock];
}

- (void)textFieldDidChange {
  [self didChangeEmail:self.emailField.text];
}

- (void)didChangeEmail:(NSString *)emailText {
  self.navigationItem.rightBarButtonItem.enabled = (emailText.length > 0);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FUIAuthTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
  if (!cell) {
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([FUIAuthTableViewCell class])
                                    bundle:[FUIAuthUtils authUIBundle]];
    [tableView registerNib:cellNib forCellReuseIdentifier:kCellReuseIdentifier];
    cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
  }
  cell.label.text = FUILocalizedString(kStr_Email);
  cell.textField.placeholder = FUILocalizedString(kStr_ConfirmEmail);
  cell.textField.delegate = self;
  cell.accessibilityIdentifier = kEmailCellAccessibilityID;
  self.emailField = cell.textField;
  cell.textField.secureTextEntry = NO;
  cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
  cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  cell.textField.returnKeyType = UIReturnKeyNext;
  cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
  if (@available(iOS 11.0, *)) {
    cell.textField.textContentType = UITextContentTypeUsername;
  }
  [cell.textField addTarget:self
                     action:@selector(textFieldDidChange)
           forControlEvents:UIControlEventEditingChanged];
  [self didChangeEmail:self.emailField.text];
  return cell;
}

- (nullable id<FUIAuthProvider>)bestProviderFromProviderIDs:(NSArray<NSString *> *)providerIDs {
  NSArray<id<FUIAuthProvider>> *providers = self.authUI.providers;
  for (NSString *providerID in providerIDs) {
    for (id<FUIAuthProvider> provider in providers) {
      if ([providerID isEqual:provider.providerID]) {
        return provider;
      }
    }
  }
  return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.emailField) {
    [self onNext:self.emailField.text];
  }
  return NO;
}

#pragma mark - Utilities

/** @fn signInWithProvider:email:
    @brief Actually kicks off sign in with the provider.
    @param provider The identity provider to sign in with.
    @param email The email address of the user.
 */
- (void)signInWithProvider:(id<FUIAuthProvider>)provider email:(NSString *)email {
  [self incrementActivity];

  // Sign out first to make sure sign in starts with a clean state.
  [provider signOut];
  [provider signInWithDefaultValue:email
          presentingViewController:self
                        completion:^(FIRAuthCredential * _Nullable credential,
                                     NSError * _Nullable error,
                                     FIRAuthResultCallback  _Nullable result,
                                     NSDictionary<NSString *,id> * _Nullable userInfo) {
    if (error) {
      [self decrementActivity];
      if (result) {
        result(nil, error);
      }

      [self dismissNavigationControllerAnimated:YES completion:^{
        [self.authUI invokeResultCallbackWithAuthDataResult:nil URL:nil error:error];
      }];
      return;
    }

    [self.auth signInWithCredential:credential
                         completion:^(FIRAuthDataResult *_Nullable authResult,
                                      NSError *_Nullable error) {
        [self decrementActivity];
        if (result) {
          result(authResult.user, error);
        }

        if (error) {
          [self.authUI invokeResultCallbackWithAuthDataResult:nil URL:nil error:error];
        } else {
          [self dismissNavigationControllerAnimated:YES completion:^{
            [self.authUI invokeResultCallbackWithAuthDataResult:authResult URL:nil error:error];
          }];
        }
      }];
    }];
}

@end
