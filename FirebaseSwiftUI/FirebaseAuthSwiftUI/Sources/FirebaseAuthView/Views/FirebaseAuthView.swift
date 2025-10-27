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

public struct FirebaseAuthView<Content: View>: View {
  public init(
    authService: AuthService,
    isPresented: Binding<Bool> = .constant(false),
    interactiveDismissDisabled: Bool = true,
    @ViewBuilder content: @escaping () -> Content = { EmptyView() }
  ) {
    self.authService = authService
    self.isPresented = isPresented
    self.interactiveDismissDisabled = interactiveDismissDisabled
    self.content = content
  }
  
  private var authService: AuthService
  private var isPresented: Binding<Bool>
  private var interactiveDismissDisabled: Bool
  private let content: () -> Content?
  
  
  public var body: some View {
    content()
      .sheet(isPresented: isPresented) {
        FirebaseAuthViewInternal(
          authService: authService,
          interactiveDismissDisabled: interactiveDismissDisabled
        )
      }
  }
}
