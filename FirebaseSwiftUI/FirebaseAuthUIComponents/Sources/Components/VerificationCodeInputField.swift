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
import UIKit

public struct VerificationCodeInputField: View {
  public init(code: Binding<String>,
              codeLength: Int = 6,
              isError: Bool = false,
              errorMessage: String? = nil,
              validations: [FormValidator] = [],
              maintainsValidationMessage: Bool = false,
              onCodeComplete: @escaping (String) -> Void = { _ in },
              onCodeChange: @escaping (String) -> Void = { _ in }) {
    _code = code
    self.codeLength = codeLength
    self.isError = isError
    self.errorMessage = errorMessage
    self.validations = validations
    self.maintainsValidationMessage = maintainsValidationMessage
    self.onCodeComplete = onCodeComplete
    self.onCodeChange = onCodeChange
    _digitFields = State(initialValue: Array(repeating: "", count: codeLength))
  }

  @Binding var code: String
  let codeLength: Int
  let isError: Bool
  let errorMessage: String?
  let validations: [FormValidator]
  let maintainsValidationMessage: Bool
  let onCodeComplete: (String) -> Void
  let onCodeChange: (String) -> Void

  @State private var digitFields: [String] = []
  @State private var focusedIndex: Int? = nil
  @State private var pendingInternalCodeUpdates = 0
  @State private var hasInteracted: Bool = false

  private var allRequirementsMet: Bool {
    validations.allSatisfy { $0.isValid(input: code) }
  }

  public var body: some View {
    VStack(spacing: 8) {
      HStack(spacing: 8) {
        ForEach(0 ..< codeLength, id: \.self) { index in
          SingleDigitField(
            digit: $digitFields[index],
            isError: isError,
            isFocused: focusedIndex == index,
            maxDigits: codeLength - index,
            position: index + 1,
            totalDigits: codeLength,
            onDigitChanged: { newDigit in
              handleDigitChanged(at: index, newDigit: newDigit)
            },
            onBackspace: {
              handleBackspace(at: index)
            },
            onFocusChanged: { isFocused in
              DispatchQueue.main.async {
                if isFocused {
                  if focusedIndex != index {
                    withAnimation(.easeInOut(duration: 0.2)) {
                      focusedIndex = index
                    }
                  }
                } else if focusedIndex == index {
                  withAnimation(.easeInOut(duration: 0.2)) {
                    focusedIndex = nil
                  }
                }
              }
            }
          )
        }
      }

      if isError, let errorMessage = errorMessage {
        Text(errorMessage)
          .font(.caption)
          .foregroundColor(.red)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      if !validations
        .isEmpty && hasInteracted && (maintainsValidationMessage || !allRequirementsMet) {
        VStack(alignment: .leading, spacing: 4) {
          ForEach(validations) { validator in
            let isValid = validator.isValid(input: code)
            Text(validator.message)
              .font(.caption)
              .strikethrough(isValid, color: .gray)
              .foregroundStyle(isValid ? .gray : .red)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .onAppear {
      // Initialize digit fields from the code binding
      updateDigitFieldsFromCode(shouldUpdateFocus: true, forceFocus: true)
    }
    .onChange(of: code) { _, _ in
      if !hasInteracted && !code.isEmpty {
        hasInteracted = true
      }
      if pendingInternalCodeUpdates > 0 {
        pendingInternalCodeUpdates -= 1
        return
      }
      updateDigitFieldsFromCode(shouldUpdateFocus: true)
    }
  }

  private func updateDigitFieldsFromCode(shouldUpdateFocus: Bool, forceFocus: Bool = false) {
    let sanitized = code.filter { $0.isNumber }
    let truncated = String(sanitized.prefix(codeLength))
    var newFields = Array(repeating: "", count: codeLength)

    for (offset, character) in truncated.enumerated() {
      newFields[offset] = String(character)
    }

    let fieldsChanged = newFields != digitFields
    if fieldsChanged {
      digitFields = newFields
    }

    if code != truncated {
      commitCodeChange(truncated)
    }

    if shouldUpdateFocus && (fieldsChanged || forceFocus) {
      let newFocus = truncated.count < codeLength ? truncated.count : nil
      DispatchQueue.main.async {
        withAnimation(.easeInOut(duration: 0.2)) {
          focusedIndex = newFocus
        }
      }
    }

    if fieldsChanged && truncated.count == codeLength {
      DispatchQueue.main.async {
        onCodeComplete(truncated)
      }
    }
  }

  private func commitCodeChange(_ newCode: String) {
    if code != newCode {
      pendingInternalCodeUpdates += 1
      code = newCode
    }
  }

  private func handleDigitChanged(at index: Int, newDigit: String) {
    let sanitized = newDigit.filter { $0.isNumber }

    guard !sanitized.isEmpty else {
      processSingleDigitInput(at: index, digit: "")
      return
    }

    let firstDigit = String(sanitized.prefix(1))
    processSingleDigitInput(at: index, digit: firstDigit)

    let remainder = String(sanitized.dropFirst())
    let availableSlots = max(codeLength - (index + 1), 0)
    if availableSlots > 0 {
      let trimmedRemainder = String(remainder.prefix(availableSlots))
      if !trimmedRemainder.isEmpty {
        applyBulkInput(startingAt: index + 1, digits: trimmedRemainder)
      }
    }
  }

  private func processSingleDigitInput(at index: Int, digit: String) {
    if digitFields[index] != digit {
      digitFields[index] = digit
    }

    let newCode = digitFields.joined()
    commitCodeChange(newCode)
    onCodeChange(newCode)

    if !digit.isEmpty,
       let nextIndex = findNextEmptyField(startingFrom: index) {
      DispatchQueue.main.async {
        if focusedIndex != nextIndex {
          withAnimation(.easeInOut(duration: 0.2)) {
            focusedIndex = nextIndex
          }
        }
      }
    }

    if newCode.count == codeLength {
      DispatchQueue.main.async {
        onCodeComplete(newCode)
      }
    }
  }

  private func handleBackspace(at index: Int) {
    // If current field is empty, move to previous field and clear it
    if digitFields[index].isEmpty && index > 0 {
      digitFields[index - 1] = ""
      DispatchQueue.main.async {
        let previousIndex = index - 1
        if focusedIndex != previousIndex {
          withAnimation(.easeInOut(duration: 0.2)) {
            focusedIndex = previousIndex
          }
        }
      }
    } else {
      // Clear current field
      digitFields[index] = ""
    }

    // Update the main code string
    let newCode = digitFields.joined()
    commitCodeChange(newCode)
    onCodeChange(newCode)
  }

  private func applyBulkInput(startingAt index: Int, digits: String) {
    guard !digits.isEmpty, index < codeLength else { return }

    var updatedFields = digitFields
    var currentIndex = index

    for digit in digits where currentIndex < codeLength {
      updatedFields[currentIndex] = String(digit)
      currentIndex += 1
    }

    if digitFields != updatedFields {
      digitFields = updatedFields
    }

    let newCode = updatedFields.joined()
    commitCodeChange(newCode)
    onCodeChange(newCode)

    if newCode.count == codeLength {
      DispatchQueue.main.async {
        onCodeComplete(newCode)
      }
    } else {
      let clampedIndex = max(min(currentIndex - 1, codeLength - 1), 0)
      if let nextIndex = findNextEmptyField(startingFrom: clampedIndex) {
        DispatchQueue.main.async {
          if focusedIndex != nextIndex {
            withAnimation(.easeInOut(duration: 0.2)) {
              focusedIndex = nextIndex
            }
          }
        }
      }
    }
  }

  private func findNextEmptyField(startingFrom index: Int) -> Int? {
    // Look for the next empty field after the current index
    for i in (index + 1) ..< codeLength {
      if digitFields[i].isEmpty {
        return i
      }
    }
    // If no empty field found after current index, look from the beginning
    for i in 0 ..< index {
      if digitFields[i].isEmpty {
        return i
      }
    }
    return nil
  }
}

private struct SingleDigitField: View {
  @Binding var digit: String
  let isError: Bool
  let isFocused: Bool
  let maxDigits: Int
  let position: Int
  let totalDigits: Int
  let onDigitChanged: (String) -> Void
  let onBackspace: () -> Void
  let onFocusChanged: (Bool) -> Void

  private var borderWidth: CGFloat {
    if isError { return 2 }
    if isFocused || !digit.isEmpty { return 3 }
    return 1
  }

  private var borderColor: Color {
    if isError { return .red }
    if isFocused || !digit.isEmpty { return .accentColor }
    return Color(.systemFill)
  }

  var body: some View {
    BackspaceAwareTextField(
      text: $digit,
      isFirstResponder: isFocused,
      onDeleteBackwardWhenEmpty: {
        if digit.isEmpty {
          onBackspace()
        } else {
          digit = ""
        }
      },
      onFocusChanged: { isFocused in
        onFocusChanged(isFocused)
      },
      maxCharacters: maxDigits,
      configuration: { textField in
        textField.font = .systemFont(ofSize: 24, weight: .medium)
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.textContentType = .oneTimeCode
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
      },
      onTextChange: { newValue in
        onDigitChanged(newValue)
      }
    )
    .frame(width: 48, height: 48)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.accentColor.opacity(0.05))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(borderColor, lineWidth: borderWidth)
        )
    )
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Digit \(position) of \(totalDigits)")
    .accessibilityValue(digit.isEmpty ? "Empty" : digit)
    .accessibilityHint("Enter verification code digit")
    .animation(.easeInOut(duration: 0.2), value: isFocused)
    .animation(.easeInOut(duration: 0.2), value: digit)
  }
}

private struct BackspaceAwareTextField: UIViewRepresentable {
  @Binding var text: String
  var isFirstResponder: Bool
  let onDeleteBackwardWhenEmpty: () -> Void
  let onFocusChanged: (Bool) -> Void
  let maxCharacters: Int
  let configuration: (UITextField) -> Void
  let onTextChange: (String) -> Void

  func makeUIView(context: Context) -> BackspaceUITextField {
    context.coordinator.parent = self
    let textField = BackspaceUITextField()
    textField.delegate = context.coordinator
    textField.addTarget(
      context.coordinator,
      action: #selector(Coordinator.editingChanged(_:)),
      for: .editingChanged
    )
    configuration(textField)
    textField.onDeleteBackward = { [weak textField] in
      guard let textField else { return }
      if (textField.text ?? "").isEmpty {
        onDeleteBackwardWhenEmpty()
      }
    }
    return textField
  }

  func updateUIView(_ uiView: BackspaceUITextField, context: Context) {
    context.coordinator.parent = self
    if uiView.text != text {
      uiView.text = text
    }

    uiView.onDeleteBackward = { [weak uiView] in
      guard let uiView else { return }
      if (uiView.text ?? "").isEmpty {
        onDeleteBackwardWhenEmpty()
      }
    }

    if isFirstResponder {
      if !context.coordinator.isFirstResponder {
        context.coordinator.isFirstResponder = true
        DispatchQueue.main.async { [weak uiView] in
          guard let uiView, !uiView.isFirstResponder else { return }
          uiView.becomeFirstResponder()
        }
      }
    } else if context.coordinator.isFirstResponder {
      context.coordinator.isFirstResponder = false
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  final class Coordinator: NSObject, UITextFieldDelegate {
    var parent: BackspaceAwareTextField
    var isFirstResponder = false

    init(parent: BackspaceAwareTextField) {
      self.parent = parent
    }

    @objc func editingChanged(_ sender: UITextField) {
      let updatedText = sender.text ?? ""
      parent.text = updatedText
      parent.onTextChange(updatedText)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
      isFirstResponder = true
      animateFocusChange(for: textField, focused: true)
      parent.onFocusChanged(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
      isFirstResponder = false
      animateFocusChange(for: textField, focused: false)
      parent.onFocusChanged(false)
    }

    private func animateFocusChange(for textField: UITextField, focused: Bool) {
      let targetTransform: CGAffineTransform = focused ? CGAffineTransform(scaleX: 1.05, y: 1.05) :
        .identity
      UIView.animate(
        withDuration: 0.2,
        delay: 0,
        options: [.curveEaseInOut, .allowUserInteraction]
      ) {
        textField.transform = targetTransform
      }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
      if string.isEmpty {
        return true
      }

      let digitsOnly = string.filter { $0.isNumber }
      guard !digitsOnly.isEmpty else {
        return false
      }

      let currentText = textField.text ?? ""
      let nsCurrent = currentText as NSString

      if digitsOnly.count > 1 || string.count > 1 {
        let limit = max(parent.maxCharacters, 1)
        let truncated = String(digitsOnly.prefix(limit))
        let proposed = nsCurrent.replacingCharacters(in: range, with: truncated)
        parent.onTextChange(String(proposed.prefix(limit)))
        return false
      }

      let updated = nsCurrent.replacingCharacters(in: range, with: digitsOnly)
      return updated.count <= 1
    }
  }
}

private final class BackspaceUITextField: UITextField {
  var onDeleteBackward: (() -> Void)?

  override func deleteBackward() {
    let wasEmpty = (text ?? "").isEmpty
    super.deleteBackward()
    if wasEmpty {
      onDeleteBackward?()
    }
  }
}

// MARK: - Preview

#Preview("Normal State") {
  @Previewable @State var code = ""

  return VStack(spacing: 32) {
    Text("Enter Verification Code")
      .font(.title2)
      .fontWeight(.semibold)

    VerificationCodeInputField(
      code: $code,
      onCodeComplete: { completedCode in
        print("Code completed: \(completedCode)")
      },
      onCodeChange: { newCode in
        print("Code changed: \(newCode)")
      }
    )

    Text("Current code: \(code)")
      .font(.caption)
      .foregroundColor(.secondary)
  }
  .padding()
}

#Preview("Error State") {
  @Previewable @State var code = "12345"

  return VStack(spacing: 32) {
    Text("Enter Verification Code")
      .font(.title2)
      .fontWeight(.semibold)

    VerificationCodeInputField(
      code: $code,
      isError: true,
      errorMessage: "Invalid verification code",
      onCodeComplete: { completedCode in
        print("Code completed: \(completedCode)")
      },
      onCodeChange: { newCode in
        print("Code changed: \(newCode)")
      }
    )

    Text("Current code: \(code)")
      .font(.caption)
      .foregroundColor(.secondary)
  }
  .padding()
}

#Preview("Custom Length") {
  @Previewable @State var code = ""

  return VStack(spacing: 32) {
    Text("Enter 4-Digit Code")
      .font(.title2)
      .fontWeight(.semibold)

    VerificationCodeInputField(
      code: $code,
      codeLength: 4,
      onCodeComplete: { completedCode in
        print("Code completed: \(completedCode)")
      },
      onCodeChange: { newCode in
        print("Code changed: \(newCode)")
      }
    )

    Text("Current code: \(code)")
      .font(.caption)
      .foregroundColor(.secondary)
  }
  .padding()
}
