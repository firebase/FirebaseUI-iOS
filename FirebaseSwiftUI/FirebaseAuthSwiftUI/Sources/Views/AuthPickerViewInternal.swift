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
import FirebaseAuthUIComponents

struct AuthPickerViewInternal: View {
  @Environment(AuthService.self) private var authService
  
  var body: some View {
    @Bindable var authService = authService
    VStack {
      if authService.authenticationState == .authenticated {
        SignedInView()
      } else {
        authMethodPicker
          .safeAreaPadding()
      }
    }
    .navigationTitle(authService.authenticationState == .unauthenticated ? authService
      .string.authPickerTitle : "")
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      toolbar
    }
    .overlay {
      if authService.authenticationState == .authenticating {
        VStack(spacing: 24) {
          ProgressView()
            .scaleEffect(1.25)
            .tint(.white)
          Text("Authenticating...")
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.7))
      }
    }
    .errorAlert(
      error: authService.currentError,
      okButtonLabel: authService.string.okButtonLabel
    )
  }
  
  @ToolbarContentBuilder
  var toolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      if !authService.configuration.shouldHideCancelButton {
        Button {
          authService.isPresented = false
        } label: {
          Image(systemName: "xmark")
            .foregroundStyle(Color(UIColor.label))
        }
      }
    }
  }
  
  @ViewBuilder
  var authMethodPicker: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 24) {
          Image(authService.configuration.logo ?? Assets.firebaseAuthLogo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
          if authService.emailSignInEnabled {
            EmailAuthView()
          }
          Divider()
          otherSignInOptions(proxy)
          PrivacyTOCsView(displayMode: .full)
        }
      }
    }
  }
  
  @ViewBuilder
  func otherSignInOptions(_ proxy: GeometryProxy) -> some View {
    VStack {
      authService.renderButtons()
    }
    .padding(.horizontal, proxy.size.width * 0.18)
  }
}
