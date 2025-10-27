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

/// A reusable view modifier that displays error messages in an alert modal
struct ErrorAlertModifier: ViewModifier {
  @Binding var error: AlertError?
  let okButtonLabel: String

  func body(content: Content) -> some View {
    content
      .alert(isPresented: Binding<Bool>(
        get: { error != nil },
        set: { if !$0 { error = nil } }
      )) {
        Alert(
          title: Text(error?.title ?? "Error"),
          message: Text(error?.message ?? ""),
          dismissButton: .default(Text(okButtonLabel)) {
            error = nil
          }
        )
      }
  }
}

/// Extension to make it easy to apply the error alert modifier
public extension View {
  func errorAlert(error: Binding<AlertError?>, okButtonLabel: String = "OK") -> some View {
    modifier(ErrorAlertModifier(error: error, okButtonLabel: okButtonLabel))
  }
}

/// A struct to represent an error that should be displayed in an alert
public struct AlertError: Identifiable {
  public let id = UUID()
  public let title: String
  public let message: String

  public init(title: String = "Error", message: String) {
    self.title = title
    self.message = message
  }
}
