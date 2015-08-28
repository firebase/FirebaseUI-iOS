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
#import <Social/Social.h>
#import "FirebaseTwitterAuthHelper.h"

@interface FirebaseTwitterAuthHelper ()
@property(strong, nonatomic) ACAccount *account;
@property(nonatomic, copy) void (^userCallback)(NSError *, FAuthData *);
@end

@implementation FirebaseTwitterAuthHelper

@synthesize store;
@synthesize ref;
@synthesize apiKey;
@synthesize account;
@synthesize accounts;
@synthesize userCallback;

NSString *const CLASS_NAME = @"FirebaseTwitterAuthHelper";

- (id)initWithFirebaseRef:(Firebase *)aRef
                   apiKey:(NSString *)anApiKey
                 delegate:(id)delegate {
  self = [super init];
  if (self) {
    self.store = [[ACAccountStore alloc] init];
    self.ref = aRef;
    self.apiKey = anApiKey;
    self.delegate = delegate;

    [self.ref observeAuthEventWithBlock:^(FAuthData *authData) {
      [self.delegate onAuthStageChange:authData];
    }];
  }
  return self;
}

// Step 1a -- get account
- (void)selectTwitterAccountWithCallback:(void (^)(NSError *error,
                                                   NSArray *accounts))callback {
  ACAccountType *accountType = [self.store
      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

  [self.store
      requestAccessToAccountsWithType:accountType
                              options:nil
                           completion:^(BOOL granted, NSError *error) {
                             if (granted) {
                               self.accounts = [self.store
                                   accountsWithAccountType:accountType];
                               if ([self.accounts count] > 0) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                   callback(nil, self.accounts);
                                 });
                               } else {
                                 NSError *error = [[NSError alloc]
                                     initWithDomain:CLASS_NAME
                                               code:
                                                   AuthHelperErrorAccountAccessDenied
                                           userInfo:@{
                                             NSLocalizedDescriptionKey :
                                                 @"No Twitter accounts "
                                             @"detected on phone. Please "
                                             @"add one in the settings "
                                             @"first."
                                           }];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                   callback(error, nil);
                                 });
                               }
                             } else {
                               NSError *error = [[NSError alloc]
                                   initWithDomain:CLASS_NAME
                                             code:
                                                 AuthHelperErrorAccountAccessDenied
                                         userInfo:@{
                                           NSLocalizedDescriptionKey :
                                               @"Access to twitter accounts "
                                           @"denied."
                                         }];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                 callback(error, nil);
                               });
                             }
                           }];
}

// Last public facing method
- (void)authenticateAccount:(ACAccount *)anAccount
               withCallback:
                   (void (^)(NSError *error, FAuthData *authData))callback {
  if (!anAccount) {
    NSError *error =
        [[NSError alloc] initWithDomain:CLASS_NAME
                                   code:AuthHelperErrorAccountAccessDenied
                               userInfo:@{
                                 NSLocalizedDescriptionKey :
                                     @"No Twitter account to authenticate."
                               }];
    callback(error, nil);
  } else {
    self.account = anAccount;
    self.userCallback = callback;
    [self makeReverseRequest];  // kick off step 1b
  }
}

- (void)callbackIfExistsWithError:(NSError *)error
                         authData:(FAuthData *)authData {
  if (self.userCallback) {
    self.userCallback(error, authData);
  }
}

// Step 1b -- get request token from Twitter
- (void)makeReverseRequest {
  [self.ref makeReverseOAuthRequestTo:@"twitter"
                  withCompletionBlock:^(NSError *error, NSDictionary *json) {
                    if (error != nil) {
                      [self callbackIfExistsWithError:error authData:nil];
                    } else {
                      SLRequest *request = [self
                          createCredentialRequestWithReverseAuthPayload:json];
                      [self requestTwitterCredentials:request];
                    }
                  }];
}

// Step 1b Helper -- creates request to Twitter
- (SLRequest *)createCredentialRequestWithReverseAuthPayload:
    (NSDictionary *)json {
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

  NSString *requestToken = [json objectForKey:@"oauth"];
  [params setValue:requestToken forKey:@"x_reverse_auth_parameters"];
  [params setValue:self.apiKey forKey:@"x_reverse_auth_target"];

  NSURL *url =
      [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
  SLRequest *req = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                      requestMethod:SLRequestMethodPOST
                                                URL:url
                                         parameters:params];
  [req setAccount:self.account];

  return req;
}

// Step 2 -- request credentials from Twitter
- (void)requestTwitterCredentials:(SLRequest *)request {
  [request performRequestWithHandler:^(NSData *responseData,
                                       NSHTTPURLResponse *urlResponse,
                                       NSError *error) {
    if (error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self callbackIfExistsWithError:error authData:nil];
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
    // There was an error handling the parameters, error out.
    NSError *error = [[NSError alloc]
        initWithDomain:CLASS_NAME
                  code:AuthHelperErrorOAuthTokenRequestDenied
              userInfo:@{
                NSLocalizedDescriptionKey : @"OAuth token request was denied.",
                @"details" : params[@"error"]
              }];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self callbackIfExistsWithError:error authData:nil];
    });
  } else {
    [self.ref authWithOAuthProvider:@"twitter"
                         parameters:params
                withCompletionBlock:self.userCallback];
  }
}

// Step 3 Helper -- parsers credentials into dictionary
- (NSDictionary *)parseTwitterCredentials:(NSData *)responseData {
  NSString *accountData = [[NSString alloc] initWithData:responseData
                                                encoding:NSUTF8StringEncoding];
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

- (void)dealloc {
  [self.ref removeAllObservers];
}

@end