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

import Combine
@preconcurrency import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseAuthUIComponents
import SwiftUI
import UIKit

public typealias VerificationID = String

// MARK: - Phone Auth Coordinator

@MainActor
private class PhoneAuthCoordinator: ObservableObject {
  @Published var isPresented = true
  @Published var currentStep: Step = .enterPhoneNumber
  @Published var phoneNumber = ""
  @Published var selectedCountry: CountryData = .default
  @Published var verificationID = ""
  @Published var fullPhoneNumber = ""
  @Published var verificationCode = ""
  @Published var currentError: AlertError?
  @Published var isProcessing = false
  
  var continuation: CheckedContinuation<AuthCredential, Error>?
  
  enum Step {
    case enterPhoneNumber
    case enterVerificationCode
  }
  
  func sendVerificationCode() async {
    isProcessing = true
    do {
      fullPhoneNumber = selectedCountry.dialCode + phoneNumber
      verificationID = try await withCheckedThrowingContinuation { continuation in
        PhoneAuthProvider.provider()
          .verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
              continuation.resume(throwing: error)
              return
            }
            continuation.resume(returning: verificationID!)
          }
      }
      currentStep = .enterVerificationCode
      currentError = nil
    } catch {
      currentError = AlertError(message: error.localizedDescription)
    }
    isProcessing = false
  }
  
  func verifyCodeAndComplete() async {
    isProcessing = true
    do {
      let credential = PhoneAuthProvider.provider()
        .credential(withVerificationID: verificationID, verificationCode: verificationCode)
      
      isPresented = false
      continuation?.resume(returning: credential)
      continuation = nil
    } catch {
      currentError = AlertError(message: error.localizedDescription)
      isProcessing = false
    }
  }
  
  func cancel() {
    isPresented = false
    continuation?.resume(throwing: AuthServiceError.signInCancelled("Phone authentication was cancelled"))
    continuation = nil
  }
}

// MARK: - Phone Auth Flow View

@MainActor
private struct PhoneAuthFlowView: View {
  @StateObject var coordinator: PhoneAuthCoordinator
  @Environment(AuthService.self) private var authService
  
  var body: some View {
    NavigationStack {
      Group {
        switch coordinator.currentStep {
        case .enterPhoneNumber:
          phoneNumberView
        case .enterVerificationCode:
          verificationCodeView
        }
      }
      .toolbar {
        toolbar
      }
    }
    .interactiveDismissDisabled(authService.configuration.interactiveDismissEnabled)
  }
  
  @ToolbarContentBuilder
  var toolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      if !authService.configuration.shouldHideCancelButton {
        Button {
          coordinator.cancel()
        } label: {
          Image(systemName: "xmark")
        }
      }
    }
  }
  
  // MARK: - Phone Number View
  
  var phoneNumberView: some View {
    VStack(spacing: 16) {
      Text(authService.string.enterPhoneNumberPlaceholder)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)

      AuthTextField(
        text: $coordinator.phoneNumber,
        localizedTitle: "Phone",
        prompt: authService.string.enterPhoneNumberPlaceholder,
        keyboardType: .phonePad,
        contentType: .telephoneNumber,
        onChange: { _ in }
      ) {
        CountrySelector(
          selectedCountry: $coordinator.selectedCountry,
          enabled: !coordinator.isProcessing
        )
      }

      Button(action: {
        Task {
          await coordinator.sendVerificationCode()
        }
      }) {
        if coordinator.isProcessing {
          ProgressView()
            .frame(height: 32)
            .frame(maxWidth: .infinity)
        } else {
          Text(authService.string.sendCodeButtonLabel)
            .frame(height: 32)
            .frame(maxWidth: .infinity)
        }
      }
      .buttonStyle(.borderedProminent)
      .disabled(coordinator.isProcessing || coordinator.phoneNumber.isEmpty)
      .padding(.top, 8)

      Spacer()
    }
    .navigationTitle(authService.string.phoneSignInTitle)
    .padding(.horizontal)
    .errorAlert(error: $coordinator.currentError, okButtonLabel: authService.string.okButtonLabel)
  }
  
  // MARK: - Verification Code View
  
  var verificationCodeView: some View {
    VStack(spacing: 32) {
      VStack(spacing: 16) {
        VStack(spacing: 8) {
          Text("We sent a code to \(coordinator.fullPhoneNumber)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)

          Button {
            coordinator.currentStep = .enterPhoneNumber
            coordinator.verificationCode = ""
          } label: {
            Text("Change number")
              .font(.caption)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity, alignment: .leading)

        VerificationCodeInputField(
          code: $coordinator.verificationCode,
          isError: coordinator.currentError != nil,
          errorMessage: coordinator.currentError?.message
        )

        Button(action: {
          Task {
            await coordinator.verifyCodeAndComplete()
          }
        }) {
          if coordinator.isProcessing {
            ProgressView()
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          } else {
            Text(authService.string.verifyAndSignInButtonLabel)
              .frame(height: 32)
              .frame(maxWidth: .infinity)
          }
        }
        .buttonStyle(.borderedProminent)
        .disabled(coordinator.isProcessing || coordinator.verificationCode.count != 6)
      }

      Spacer()
    }
    .navigationTitle(authService.string.enterVerificationCodeTitle)
    .navigationBarTitleDisplayMode(.inline)
    .padding(.horizontal)
    .errorAlert(error: $coordinator.currentError, okButtonLabel: authService.string.okButtonLabel)
  }
}

// MARK: - Phone Provider Swift

public class PhoneProviderSwift: PhoneAuthProviderSwift {
  private var cancellables = Set<AnyCancellable>()
  
  // Internal use only: Injected automatically by AuthService.signIn()
  public weak var authService: AuthService?
  
  public init() {}

  @MainActor public func createAuthCredential() async throws -> AuthCredential {
    guard let authService = authService else {
      throw AuthServiceError.providerAuthenticationFailed(
        "AuthService not injected. This should be set automatically by AuthService.signIn()."
      )
    }
    
    // Get the root view controller to present from
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
      throw AuthServiceError.rootViewControllerNotFound(
        "Root view controller not available to present phone auth flow"
      )
    }
    
    // Find the topmost view controller
    var topViewController = rootViewController
    while let presented = topViewController.presentedViewController {
      topViewController = presented
    }
    
    // Create coordinator
    let coordinator = PhoneAuthCoordinator()
    
    // Present the flow and wait for result
    return try await withCheckedThrowingContinuation { continuation in
      coordinator.continuation = continuation
      
      // Create SwiftUI view with environment
      let flowView = PhoneAuthFlowView(coordinator: coordinator)
        .environment(authService)
      
      let hostingController = UIHostingController(rootView: flowView)
      
      // Dismiss handler - watch for presentation state changes
      coordinator.$isPresented.sink { [weak hostingController] isPresented in
        if !isPresented {
          hostingController?.dismiss(animated: true)
        }
      }.store(in: &cancellables)
      
      // Present modally
      topViewController.present(hostingController, animated: true)
    }
  }
}

public class PhoneAuthProviderAuthUI: AuthProviderUI {
  public var provider: AuthProviderSwift
  public let id: String = "phone"

  public init(provider: PhoneAuthProviderSwift? = nil) {
    self.provider = provider ?? PhoneProviderSwift()
  }

  @MainActor public func authButton() -> AnyView {
    AnyView(PhoneAuthButtonView(phoneProvider: provider as! PhoneAuthProviderSwift))
  }
}
