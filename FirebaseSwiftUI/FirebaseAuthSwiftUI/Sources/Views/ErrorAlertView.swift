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

import FirebaseAuth
import SwiftUI

/// A reusable view modifier that displays error messages in an alert modal
struct ErrorAlertModifier: ViewModifier {
  @Binding var error: AlertError?
  let okButtonLabel: String

  private func shouldShowAlert(for error: AlertError?) -> Bool {
    // View layer decides which errors should show an alert
    guard let error = error else { return false }

    // Don't show alert for CancellationError
    if error.underlyingError is CancellationError {
      return false
    }

    return true
  }

  func body(content: Content) -> some View {
    let shouldShow = shouldShowAlert(for: error)

    return content
      .alert(isPresented: Binding<Bool>(
        get: { shouldShow },
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
public struct AlertError: Identifiable, Equatable {
  public let id = UUID()
  public let title: String
  public let message: String
  public let underlyingError: Error?

  public init(title: String = "Error", message: String, underlyingError: Error? = nil) {
    self.title = title
    self.message = message
    self.underlyingError = underlyingError
  }

  public static func == (lhs: AlertError, rhs: AlertError) -> Bool {
    // Compare by id since each AlertError instance is unique
    lhs.id == rhs.id
  }
}
