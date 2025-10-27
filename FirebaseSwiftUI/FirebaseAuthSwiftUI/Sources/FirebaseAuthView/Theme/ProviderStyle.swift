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

struct ProviderStyle {
    let icon: ImageResource?
    let backgroundColor: Color
    let contentColor: Color
    var iconTint: Color? = nil
    let shape: AnyShape = AnyShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    let elevation: CGFloat = 2
    
    static let empty = ProviderStyle(
        icon: nil,
        backgroundColor: .white,
        contentColor: .black
    )
    
    static var `default`: [String: ProviderStyle] {
        Dictionary(uniqueKeysWithValues: AuthProvider.allCases.map { provider in
            (provider.id, provider.providerStyle)
        })
    }
}
