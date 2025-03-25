import SwiftUI

public struct AuthPickerView<Content: View>: View {
  @Environment(AuthEnvironment.self) private var authEnvironment
  let providerButtons: () -> Content

  public init(@ViewBuilder providerButtons: @escaping () -> Content) {
    self.providerButtons = providerButtons
  }

  public var body: some View {
    VStack {
      providerButtons()
    }
  }
}
