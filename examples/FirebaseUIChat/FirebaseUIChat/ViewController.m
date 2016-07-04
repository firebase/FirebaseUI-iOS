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

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UIButton *signOutBtn;

@property (nonatomic) FIRAuthStateDidChangeListenerHandle authStateListener;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    __weak id weakSelf = self;
    self.authStateListener = [[FIRAuth auth]
                              addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth,
                                                              FIRUser *_Nullable user) {
                                  __strong id strongSelf = weakSelf;
                                  if(strongSelf){
                                      if (user != nil) {
                                          NSLog(@"User is signed in Listener, %@", user.providerID);
                                          self.signInBtn.hidden = YES;
                                          self.signOutBtn.hidden = NO;
                                      } else {
                                          NSLog(@"No user is signed in Listener");
                                          self.signInBtn.hidden = NO;
                                          self.signOutBtn.hidden = YES;
                                      }
                                  }
                              }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[FIRAuth auth] removeAuthStateDidChangeListener:self.authStateListener];
}

- (IBAction)signInBtnClicked:(id)sender {

    FIRAuthUI *authUI = [FIRAuthUI authUI];
    authUI.delegate = self;

    // Get client ID from [FIRApp defaultApp].options.clientID property
    // clientID is the OAuth2 client ID for iOS application used to authenticate Google users
    // API reference: https://firebase.google.com/docs/reference/ios/firebaseanalytics/interface_f_i_r_options
    FIRGoogleAuthUI *googleAuthUI = [[FIRGoogleAuthUI alloc] initWithClientID:
                                     [FIRApp defaultApp].options.clientID];

    authUI.providers = @[ googleAuthUI ];

    UIViewController *authViewController = [authUI authViewController];

    [self presentViewController:authViewController animated:YES completion:nil];

}

- (IBAction)signOutBtnClicked:(id)sender {

    NSError *signOutError;
    [[FIRAuthUI authUI].auth signOut:&signOutError];
    if (!signOutError) {
        NSLog(@"Sign-out succeeded");
        self.signInBtn.hidden = NO;
        self.signOutBtn.hidden = YES;
    }
}


- (void)authUI:(FIRAuthUI *)authUI
didSignInWithUser:(nullable FIRUser *)user
         error:(nullable NSError *)error {
    if (!error) {

#if DEBUG
        NSLog(@"didSignIn");
#endif

        self.signInBtn.hidden = YES;
        self.signOutBtn.hidden = NO;
        
    } else {
#if DEBUG
        NSLog(@"authUI didSign error = %@", error.localizedDescription);
#endif
    }
    
}
@end
