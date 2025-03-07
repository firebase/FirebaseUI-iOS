import SwiftUI

public protocol FUIButtonProtocol: View {
  var buttonContent: AnyView { get }
}

public class EmailAuthButtonConfiguration {
    public var buttonText: String = "Sign in with email"
    public var buttonPadding: CGFloat = 8
    public var buttonBackgroundColor: Color = .red
    public var buttonForegroundColor: Color = .white
    public var buttonCornerRadius: CGFloat = 8

    public init() {}
}

// Update the EmailAuthButton to use the configuration
public struct EmailAuthButton: FUIButtonProtocol {
    @State private var emailAuthView = false
    private let configuration: EmailAuthButtonConfiguration

    public init(configuration: EmailAuthButtonConfiguration = EmailAuthButtonConfiguration()) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack {
            Button(action: {
                emailAuthView = true
            }) {
                Text(configuration.buttonText)
                .padding(configuration.buttonPadding)
                .background(configuration.buttonBackgroundColor)
                .foregroundColor(configuration.buttonForegroundColor)
                .cornerRadius(configuration.buttonCornerRadius)
            }
            NavigationLink(destination: EmailEntryView(), isActive: $emailAuthView) {
                EmptyView()
            }
        }
    }
}
