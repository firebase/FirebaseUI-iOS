import SwiftUI

public protocol FUIAuthFlowBase: View {
  associatedtype Body: View
  var body: Self.Body { get }
}
