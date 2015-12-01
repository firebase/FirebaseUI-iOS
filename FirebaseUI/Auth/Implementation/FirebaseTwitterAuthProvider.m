// clang-format off

/*
 * Firebase UI Bindings iOS Library
 *
 * Copyright © 2015 Firebase - All Rights Reserved
 * https://www.firebase.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// clang-format on

#import "FirebaseTwitterAuthProvider.h"

@implementation FirebaseTwitterAuthProvider {
  ACAccountStore *_store;
  NSString *_apiKey;
}

- (instancetype)initWithRef:(Firebase *)ref
               authDelegate:(id<FirebaseAuthDelegate>)authDelegate
            twitterDelegate:(id<TwitterAuthDelegate>)twitterDelegate {
  self = [super initWithRef:ref authDelegate:authDelegate];
  if (self) {
    self.provider = FAuthProviderTwitter;
    self.twitterDelegate = twitterDelegate;
    [self configureProvider];
  }
  return self;
}

- (void)configureProvider {
  _apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:kTwitterApiKey];
  if (_apiKey == nil) {
    [NSException
         raise:NSInternalInconsistencyException
        format:
            @"Please add your Twitter API key to `TwitterApiKey` in `Supporting Files/Info.plist`"];
  }

  _store = [[ACAccountStore alloc] init];
}

- (void)login {
  [self twitterAccountsFromStore:_store
                    withCallback:^(NSArray *accounts, NSError *error) {
                      if (error) {
                        // Raise error
                        [self.delegate authProvider:self onUserError:error];
                        return;
                      }

                      switch ([accounts count]) {
                        case 0:
                          // No account
                          [self.twitterDelegate createTwitterAccount];
                          break;

                        case 1:
                          // Single account
                          [self loginWithAccount:[accounts firstObject]];
                          break;

                        default:
                          // Multiple accounts
                          [self.twitterDelegate selectTwitterAccount:accounts];
                          break;
                      }
                    }];
}

- (void)loginWithAccount:(ACAccount *)account {
  if (account) {
    [self makeReverseRequestForAccount:account];
  } else {
    NSError *error =
        [NSError errorWithDomain:NSStringFromClass(self.class)
                            code:FAuthenticationErrorUserDoesNotExist
                        userInfo:@{
                          NSLocalizedDescriptionKey :
                              @"Trying to log in without a valid Twitter account in not allowed."
                        }];
    [self.delegate authProvider:self onUserError:error];
  }
}

- (void)logout {
  [super logout];
}

#pragma mark - Twitter token requests
// Step 1a -- get account
- (void)twitterAccountsFromStore:(ACAccountStore *)store
                    withCallback:(void (^)(NSArray *accounts, NSError *error))callback {
  ACAccountType *accountType =
      [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  [store requestAccessToAccountsWithType:accountType
                                 options:nil
                              completion:^(BOOL granted, NSError *error) {
                                if (granted) {
                                  NSArray *accounts = [store accountsWithAccountType:accountType];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                    callback(accounts, nil);
                                  });
                                } else {
                                  NSError *error = [[NSError alloc]
                                      initWithDomain:NSStringFromClass(self.class)
                                                code:FAuthenticationErrorDeniedByUser
                                            userInfo:@{
                                              NSLocalizedDescriptionKey :
                                                  @"Access to twitter accounts denied."
                                            }];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                    callback(nil, error);
                                  });
                                }
                              }];
}

// Step 1b -- get request token from Twitter
- (void)makeReverseRequestForAccount:(ACAccount *)account {
  [self.ref
      makeReverseOAuthRequestTo:@"twitter"
            withCompletionBlock:^(NSError *error, NSDictionary *json) {
              if (error != nil) {
                [self.delegate authProvider:self onProviderError:error];
              } else {
                SLRequest *request =
                    [self createCredentialRequestWithReverseAuthPayload:json forAccount:account];
                [self requestTwitterCredentials:request];
              }
            }];
}

// Step 1b Helper -- creates request to Twitter
- (SLRequest *)createCredentialRequestWithReverseAuthPayload:(NSDictionary *)json
                                                  forAccount:(ACAccount *)account {
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

  NSString *requestToken = [json objectForKey:@"oauth"];
  [params setValue:requestToken forKey:@"x_reverse_auth_parameters"];
  [params setValue:_apiKey forKey:@"x_reverse_auth_target"];

  NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
  SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                          requestMethod:SLRequestMethodPOST
                                                    URL:url
                                             parameters:params];
  [request setAccount:account];

  return request;
}

// Step 2 -- request credentials from Twitter
- (void)requestTwitterCredentials:(SLRequest *)request {
  [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse,
                                       NSError *error) {
    if (error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate authProvider:self onProviderError:error];
      });
    } else {
      [self authenticateWithTwitterCredentials:responseData];
    }
  }];
}

// Step 3 -- authenticate with Firebase using Twitter credentials
- (void)authenticateWithTwitterCredentials:(NSData *)responseData {
  NSDictionary *params = [self parseTwitterCredentials:responseData];
  if (params[@"error"]) {
    NSError *error =
        [[NSError alloc] initWithDomain:NSStringFromClass(self.class)
                                   code:FAuthenticationErrorInvalidCredentials
                               userInfo:@{
                                 NSLocalizedDescriptionKey : @"OAuth token request was denied.",
                                 @"details" : params[@"error"]
                               }];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.delegate authProvider:self onProviderError:error];
    });
  } else {
    [self.ref authWithOAuthProvider:@"twitter"
                         parameters:params
                withCompletionBlock:^(NSError *error, FAuthData *authData) {
                  if (error != nil) {
                    [self handleError:error];
                  }
                }];
  }
}

// Step 3 Helper -- parsers credentials into dictionary
- (NSDictionary *)parseTwitterCredentials:(NSData *)responseData {
  NSString *accountData =
      [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

  NSArray *creds = [accountData componentsSeparatedByString:@"&"];
  for (NSString *param in creds) {
    NSArray *parts = [param componentsSeparatedByString:@"="];
    [params setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
  }

  // This is super fragile error handling, but basically check that the token
  // and token secret are there.
  // If not, return the result that Twitter returned.
  if (!params[@"oauth_token_secret"] || !params[@"oauth_token"]) {
    return @{ @"error" : accountData };
  } else {
    return params;
  }
}

@end