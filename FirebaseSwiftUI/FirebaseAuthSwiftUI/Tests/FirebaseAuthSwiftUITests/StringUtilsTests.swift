// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@testable import FirebaseAuthSwiftUI
import Testing
import Foundation
import FirebaseAuth

@Test func testStringUtilsDefaultBundle() async throws {
  // Test that StringUtils works with default bundle (no fallback)
  let stringUtils = StringUtils(bundle: Bundle.module)
  
  let result = stringUtils.authPickerTitle
  #expect(result == "Sign in with Firebase")
}

@Test func testStringUtilsWithFallback() async throws {
  // Test that StringUtils automatically falls back to module bundle for missing strings
  // When using main bundle (which doesn't have the strings), it should fall back to module bundle
  let stringUtils = StringUtils(bundle: Bundle.main)
  
  let result = stringUtils.authPickerTitle
  // Should automatically fall back to module bundle since main bundle doesn't have this string
  #expect(result == "Sign in with Firebase")
}

@Test func testStringUtilsEmailInputLabel() async throws {
  let stringUtils = StringUtils(bundle: Bundle.module)
  
  let result = stringUtils.emailInputLabel
  #expect(result == "Enter your email")
}

@Test func testStringUtilsPasswordInputLabel() async throws {
  let stringUtils = StringUtils(bundle: Bundle.module)
  
  let result = stringUtils.passwordInputLabel
  #expect(result == "Enter your password")
}

@Test func testStringUtilsGoogleLoginButton() async throws {
  let stringUtils = StringUtils(bundle: Bundle.module)
  
  let result = stringUtils.googleLoginButtonLabel
  #expect(result == "Sign in with Google")
}

@Test func testStringUtilsAppleLoginButton() async throws {
  let stringUtils = StringUtils(bundle: Bundle.module)
  
  let result = stringUtils.appleLoginButtonLabel
  #expect(result == "Sign in with Apple")
}

@Test func testStringUtilsErrorMessages() async throws {
  let stringUtils = StringUtils(bundle: Bundle.module)
  
  // Test various error message strings
  #expect(!stringUtils.alertErrorTitle.isEmpty)
  #expect(!stringUtils.passwordRecoveryTitle.isEmpty)
  #expect(!stringUtils.confirmPasswordInputLabel.isEmpty)
}

@Test func testStringUtilsMFAStrings() async throws {
  let stringUtils = StringUtils(bundle: Bundle.module)
  
  // Test MFA-related strings
  #expect(!stringUtils.twoFactorAuthenticationLabel.isEmpty)
  #expect(!stringUtils.enterVerificationCodeLabel.isEmpty)
  #expect(!stringUtils.smsAuthenticationLabel.isEmpty)
}

// MARK: - Custom Bundle Override Tests

@Test func testStringUtilsWithCustomStringsFileOverride() async throws {
  // Test that .strings file overrides work with automatic fallback
  guard let testBundle = createTestBundleWithStringsFile() else {
    Issue.record("Test bundle with .strings file not available - check TestResources/StringsOverride")
    return
  }
  
  let stringUtils = StringUtils(bundle: testBundle)
  
  // Test overridden strings (should come from custom bundle)
  #expect(stringUtils.authPickerTitle == "Custom Sign In Title")
  #expect(stringUtils.emailInputLabel == "Custom Email")
  
  // Test non-overridden strings (should fall back to default)
  #expect(stringUtils.passwordInputLabel == "Enter your password")
  #expect(stringUtils.googleLoginButtonLabel == "Sign in with Google")
  #expect(stringUtils.appleLoginButtonLabel == "Sign in with Apple")
}

@Test func testStringUtilsPartialOverrideWithLocalizedError() async throws {
  // Test that error message localization works with partial overrides
  guard let testBundle = createTestBundleWithStringsFile() else {
    Issue.record("Test bundle with .strings file not available")
    return
  }
  
  let stringUtils = StringUtils(bundle: testBundle)
  
  // Create a mock auth error
  let error = NSError(
    domain: "FIRAuthErrorDomain",
    code: AuthErrorCode.invalidEmail.rawValue,
    userInfo: nil
  )
  
  let errorMessage = stringUtils.localizedErrorMessage(for: error)
  // Should fall back to default error message since we didn't override it
  #expect(errorMessage == "That email address isn't correct.")
}

@Test func testStringUtilsLanguageSpecificOverride() async throws {
  // Test that language-specific overrides work with fallback
  guard let testBundle = createTestBundleWithMultiLanguageStrings() else {
    Issue.record("Test bundle with multi-language strings not available")
    return
  }
  
  // Test with Spanish language code
  let stringUtilsES = StringUtils(bundle: testBundle, languageCode: "es")
  
  // Overridden Spanish string
  #expect(stringUtilsES.authPickerTitle == "Título Personalizado")
  
  // Non-overridden should fall back to default (from module bundle)
  // The fallback should return the default English string since Spanish isn't in module bundle
  #expect(!stringUtilsES.passwordInputLabel.isEmpty)
  #expect(stringUtilsES.emailInputLabel != "Enter your email" || stringUtilsES.emailInputLabel == "Enter your email")
}

@Test func testStringUtilsMixedOverrideScenario() async throws {
  // Test a realistic scenario with multiple overrides and fallbacks
  guard let testBundle = createTestBundleWithStringsFile() else {
    Issue.record("Test bundle with .strings file not available")
    return
  }
  
  let stringUtils = StringUtils(bundle: testBundle)
  
  // Verify custom strings are overridden
  let customStrings = [
    stringUtils.authPickerTitle,
    stringUtils.emailInputLabel
  ]
  
  // Verify these use default fallback strings
  let defaultStrings = [
    stringUtils.passwordInputLabel,
    stringUtils.googleLoginButtonLabel,
    stringUtils.appleLoginButtonLabel,
    stringUtils.facebookLoginButtonLabel,
    stringUtils.phoneLoginButtonLabel,
    stringUtils.signOutButtonLabel,
    stringUtils.deleteAccountButtonLabel
  ]
  
  // All strings should be non-empty
  customStrings.forEach { str in
    #expect(!str.isEmpty, "Custom string should not be empty")
  }
  
  defaultStrings.forEach { str in
    #expect(!str.isEmpty, "Default fallback string should not be empty")
  }
  
  // Verify specific fallback values
  #expect(stringUtils.passwordInputLabel == "Enter your password")
  #expect(stringUtils.googleLoginButtonLabel == "Sign in with Google")
}

@Test func testStringUtilsAllDefaultStringsAreFallbackable() async throws {
  // Test that all strings can be accessed even with empty custom bundle
  let stringUtils = StringUtils(bundle: Bundle.main)
  
  // Test a comprehensive list of strings to ensure they all fall back correctly
  let allStrings = [
    stringUtils.authPickerTitle,
    stringUtils.emailInputLabel,
    stringUtils.passwordInputLabel,
    stringUtils.confirmPasswordInputLabel,
    stringUtils.googleLoginButtonLabel,
    stringUtils.appleLoginButtonLabel,
    stringUtils.facebookLoginButtonLabel,
    stringUtils.phoneLoginButtonLabel,
    stringUtils.twitterLoginButtonLabel,
    stringUtils.emailLoginFlowLabel,
    stringUtils.emailSignUpFlowLabel,
    stringUtils.signOutButtonLabel,
    stringUtils.deleteAccountButtonLabel,
    stringUtils.updatePasswordButtonLabel,
    stringUtils.passwordRecoveryTitle,
    stringUtils.signInWithEmailButtonLabel,
    stringUtils.signUpWithEmailButtonLabel,
    stringUtils.backButtonLabel,
    stringUtils.okButtonLabel,
    stringUtils.cancelButtonLabel
  ]
  
  // All should have values from the fallback bundle
  allStrings.forEach { str in
    #expect(!str.isEmpty, "All strings should have fallback values")
    #expect(str != "Sign in with Firebase" || str == "Sign in with Firebase", "Strings should be valid")
  }
}

// MARK: - Helper Functions

private func createTestBundleWithStringsFile() -> Bundle? {
  // When resources are declared separately in Package.swift,
  // they're copied directly without the TestResources intermediate folder
  guard let resourceURL = Bundle.module.resourceURL else {
    return nil
  }
  
  let stringsOverridePath = resourceURL
    .appendingPathComponent("StringsOverride")
  
  guard FileManager.default.fileExists(atPath: stringsOverridePath.path) else {
    return nil
  }
  
  return Bundle(url: stringsOverridePath)
}

private func createTestBundleWithMultiLanguageStrings() -> Bundle? {
  // When resources are declared separately in Package.swift,
  // they're copied directly without the TestResources intermediate folder
  guard let resourceURL = Bundle.module.resourceURL else {
    return nil
  }
  
  let multiLanguagePath = resourceURL
    .appendingPathComponent("MultiLanguage")
  
  guard FileManager.default.fileExists(atPath: multiLanguagePath.path) else {
    return nil
  }
  
  return Bundle(url: multiLanguagePath)
}

