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

public struct AuthTextField<Leading: View>: View {
  @FocusState private var isFocused: Bool
  @State var obscured: Bool = true
  @State var hasInteracted: Bool = false

  @Binding var text: String
  let label: String
  let prompt: String
  var textAlignment: TextAlignment = .leading
  var keyboardType: UIKeyboardType = .default
  var contentType: UITextContentType?
  var isSecureTextField: Bool = false
  var validations: [FormValidator] = []
  var maintainsValidationMessage: Bool = false
  var formState: ((Bool) -> Void)?
  var onSubmit: ((String) -> Void)?
  var onChange: ((String) -> Void)?
  private let leading: () -> Leading?

  public init(text: Binding<String>,
              label: String,
              prompt: String,
              textAlignment: TextAlignment = .leading,
              keyboardType: UIKeyboardType = .default,
              contentType: UITextContentType? = nil,
              isSecureTextField: Bool = false,
              validations: [FormValidator] = [],
              maintainsValidationMessage: Bool = false,
              formState: ((Bool) -> Void)? = nil,
              onSubmit: ((String) -> Void)? = nil,
              onChange: ((String) -> Void)? = nil,
              @ViewBuilder leading: @escaping () -> Leading? = { EmptyView() }) {
    _text = text
    self.label = label
    self.prompt = prompt
    self.textAlignment = textAlignment
    self.keyboardType = keyboardType
    self.contentType = contentType
    self.isSecureTextField = isSecureTextField
    self.validations = validations
    self.maintainsValidationMessage = maintainsValidationMessage
    self.formState = formState
    self.onSubmit = onSubmit
    self.onChange = onChange
    self.leading = leading
  }

  var allRequirementsMet: Bool {
    validations.allSatisfy { $0.isValid(input: text) }
  }

  public var body: some View {
    VStack(alignment: .leading) {
      Text(LocalizedStringResource(stringLiteral: label))
      HStack(spacing: 8) {
        leading()
        Group {
          if isSecureTextField {
            ZStack(alignment: .trailing) {
              SecureField(label, text: $text, prompt: Text(prompt))
                .opacity(obscured ? 1 : 0)
                .focused($isFocused)
                .frame(height: 24)
              TextField(label, text: $text, prompt: Text(prompt))
                .opacity(obscured ? 0 : 1)
                .focused($isFocused)
                .frame(height: 24)
              if !text.isEmpty {
                Button {
                  withAnimation(.easeInOut(duration: 0.2)) {
                    obscured.toggle()
                  }
                  // Reapply focus after toggling
                  DispatchQueue.main.async {
                    isFocused = true
                  }
                } label: {
                  Image(systemName: obscured ? "eye" : "eye.slash")
                }
                .buttonStyle(.plain)
              }
            }
          } else {
            TextField(
              label,
              text: $text,
              prompt: Text(prompt)
            )
            .frame(height: 24)
          }
        }
      }
      .frame(maxWidth: .infinity)
      .keyboardType(keyboardType)
      .textContentType(contentType)
      .autocapitalization(.none)
      .disableAutocorrection(true)
      .focused($isFocused)
      .onSubmit {
        onSubmit?(text)
      }
      .onChange(of: text) { _, newValue in
        if !hasInteracted {
          hasInteracted = true
        }
        onChange?(newValue)
      }
      .onChange(of: isFocused) { _, focused in
        if !focused && !text.isEmpty {
          hasInteracted = true
        }
      }
      .multilineTextAlignment(textAlignment)
      .textFieldStyle(.plain)
      .padding(.vertical, 12)
      .padding(.horizontal, 12)
      .background {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.accentColor.opacity(0.05))
          .strokeBorder(lineWidth: isFocused ? 3 : 1)
          .foregroundStyle(isFocused ? Color.accentColor : Color(.systemFill))
      }
      .contentShape(Rectangle())
      .onTapGesture {
        withAnimation {
          isFocused = true
        }
      }
      if !validations
        .isEmpty && hasInteracted && (maintainsValidationMessage || !allRequirementsMet) {
        VStack(alignment: .leading, spacing: 4) {
          ForEach(validations) { validator in
            let isValid = validator.isValid(input: text)
            Text(validator.message)
              .font(.caption)
              .strikethrough(isValid, color: .gray)
              .foregroundStyle(isValid ? .gray : .red)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
        .onChange(of: allRequirementsMet) { _, newValue in
          formState?(newValue)
        }
      }
    }
  }
}
