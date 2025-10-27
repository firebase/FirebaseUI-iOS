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

struct AnnotatedString: View {
  let fullText: String
  let links: [(label: String, url: String)]
  
  init(
    fullText: String,
    links: [(String, String)],
  ) {
    self.fullText = fullText
    self.links = links
  }
  
  var body: some View {
    let text = makeAttributedText()
    Text(text)
      .multilineTextAlignment(.center)
      .tint(.accentColor) // Use theme color
      .onOpenURL { url in
        // Handle URL tap (optional custom handling)
        UIApplication.shared.open(url)
      }
  }
  
  private func makeAttributedText() -> AttributedString {
    let template = fullText
    var attributed = AttributedString(template)
    
    for (label, urlString) in links {
      guard let range = attributed.range(of: label),
            let url = URL(string: urlString)
      else { continue }
      
      attributed[range].link = url
      attributed[range].foregroundColor = UIColor.tintColor
      attributed[range].underlineStyle = Text.LineStyle.single
    }
    
    return attributed
  }
}
