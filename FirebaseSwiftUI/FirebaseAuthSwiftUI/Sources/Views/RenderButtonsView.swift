//
//  RenderButtonsView.swift
//  FirebaseUI
//
//  Created by Russell Wheatley on 08/05/2025.
//
import SwiftUI

struct RenderButtonsView<Provider: ExternalAuthProvider>: View {
  var providers: [Provider] = []

  public func renderButtonViews(spacing: CGFloat = 16) -> some View {
    VStack(spacing: spacing) {
      ForEach(providers, id: \.id) { provider in
        provider.authButtonView
      }
    }
  }

  var body: some View {
    VStack {
      renderButtonViews()
    }
  }
}
