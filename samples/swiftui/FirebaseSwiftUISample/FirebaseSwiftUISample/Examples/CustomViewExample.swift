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

import SwiftUI
import FirebaseAuthSwiftUI
import FirebaseAuth

struct CustomViewExample: View {
  @Environment(AuthService.self) private var authService
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isSignUp: Bool = false
  @State private var errorMessage: String?
  @State private var isLoading: Bool = false
  
  var body: some View {
    if authService.authenticationState == .authenticated {
      authenticatedView
    } else {
      landingView
    }
  }
  
  private var landingView: some View {
    ScrollView {
      VStack(spacing: 32) {
        Spacer()
          .frame(height: 40)
        
        // Hero section
        VStack(spacing: 16) {
          Image(systemName: "flame.fill")
            .font(.system(size: 80))
            .foregroundStyle(.orange)
          
          Text("Welcome to FirebaseUI")
            .font(.largeTitle)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
          
          Text("Sign in to continue and explore all the features")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        
        Spacer()
          .frame(height: 20)
        
        // Email/Password form
        VStack(spacing: 16) {
          VStack(alignment: .leading, spacing: 8) {
            Text("Email")
              .font(.subheadline)
              .fontWeight(.medium)
            
            TextField("Enter your email", text: $email)
              .textInputAutocapitalization(.never)
              .keyboardType(.emailAddress)
              .textContentType(.emailAddress)
              .padding()
              .background(Color(UIColor.secondarySystemBackground))
              .cornerRadius(8)
          }
          
          VStack(alignment: .leading, spacing: 8) {
            Text("Password")
              .font(.subheadline)
              .fontWeight(.medium)
            
            SecureField("Enter your password", text: $password)
              .textContentType(isSignUp ? .newPassword : .password)
              .padding()
              .background(Color(UIColor.secondarySystemBackground))
              .cornerRadius(8)
          }
          
          if let errorMessage = errorMessage {
            Text(errorMessage)
              .font(.caption)
              .foregroundColor(.red)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          
          Button {
            Task {
              await handleAuthentication()
            }
          } label: {
            HStack {
              if isLoading {
                ProgressView()
                  .tint(.white)
              }
              Text(isSignUp ? "Create Account" : "Sign In")
                .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isFormValid ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
          }
          .disabled(!isFormValid || isLoading)
          
          Button {
            isSignUp.toggle()
            errorMessage = nil
          } label: {
            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
              .font(.subheadline)
              .foregroundColor(.blue)
          }
        }
        .padding(.horizontal, 24)
        
        // Divider with text
        HStack {
          Rectangle()
            .fill(Color.secondary.opacity(0.3))
            .frame(height: 1)
          
          Text("or continue with")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
          
          Rectangle()
            .fill(Color.secondary.opacity(0.3))
            .frame(height: 1)
        }
        .padding(.horizontal, 24)
        
        // Auth providers section - using AuthService's renderButtons
        VStack(spacing: 12) {
          authService.renderButtons(spacing: 12)
        }
        .padding(.horizontal, 24)
        
        Spacer()
          .frame(minHeight: 20)
        
        // Footer
        VStack(spacing: 8) {
          HStack(spacing: 4) {
            Text("By continuing, you agree to our")
              .font(.caption)
              .foregroundColor(.secondary)
            
            if let tosUrl = authService.configuration.tosUrl {
              Link("Terms", destination: tosUrl)
                .font(.caption)
            }
            
            Text("and")
              .font(.caption)
              .foregroundColor(.secondary)
            
            if let privacyUrl = authService.configuration.privacyPolicyUrl {
              Link("Privacy Policy", destination: privacyUrl)
                .font(.caption)
            }
          }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
      }
    }
  }
  
  private var authenticatedView: some View {
    VStack(spacing: 24) {
      Spacer()
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 80))
        .foregroundStyle(.green)
      
      VStack(spacing: 8) {
        Text("Signed In Successfully")
          .font(.title)
          .fontWeight(.bold)
        
        if let email = authService.currentUser?.email {
          Text(email)
            .font(.body)
            .foregroundColor(.secondary)
        } else if let phoneNumber = authService.currentUser?.phoneNumber {
          Text(phoneNumber)
            .font(.body)
            .foregroundColor(.secondary)
        }
      }
      
      Button {
        Task {
          try? await authService.signOut()
        }
      } label: {
        Text("Sign Out")
          .font(.body)
          .fontWeight(.semibold)
          .foregroundColor(.red)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(Color.red.opacity(0.1))
          .cornerRadius(8)
      }
      .padding(.horizontal, 24)
      
      Spacer()
    }
  }
  
  private var isFormValid: Bool {
    !email.isEmpty && !password.isEmpty && password.count >= 6
  }
  
  private func handleAuthentication() async {
    errorMessage = nil
    isLoading = true
    
    do {
      if isSignUp {
        _ = try await authService.createUser(email: email, password: password)
      } else {
        _ = try await authService.signIn(email: email, password: password)
      }
    } catch {
      errorMessage = error.localizedDescription
    }
    
    isLoading = false
  }
}
