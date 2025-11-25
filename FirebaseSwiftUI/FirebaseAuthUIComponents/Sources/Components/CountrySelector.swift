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

public struct CountryData: Equatable {
  public let name: String
  public let dialCode: String
  public let code: String

  public init(name: String, dialCode: String, code: String) {
    self.name = name
    self.dialCode = dialCode
    self.code = code
  }

  public var flag: String {
    let base: UInt32 = 127_397
    var s = ""
    for v in code.unicodeScalars {
      s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
  }

  @MainActor public static let `default` = CountryData(
    name: "United States",
    dialCode: "+1",
    code: "US"
  )
}

public struct CountrySelector: View {
  @Binding var selectedCountry: CountryData
  var enabled: Bool = true
  var allowedCountries: Set<String>?

  public init(selectedCountry: Binding<CountryData>,
              enabled: Bool = true,
              allowedCountries: Set<String>? = nil) {
    _selectedCountry = selectedCountry
    self.enabled = enabled
    self.allowedCountries = allowedCountries
  }

  // Common countries list
  private let allCountries: [CountryData] = [
    CountryData(name: "United States", dialCode: "+1", code: "US"),
    CountryData(name: "United Kingdom", dialCode: "+44", code: "GB"),
    CountryData(name: "Canada", dialCode: "+1", code: "CA"),
    CountryData(name: "Australia", dialCode: "+61", code: "AU"),
    CountryData(name: "Germany", dialCode: "+49", code: "DE"),
    CountryData(name: "France", dialCode: "+33", code: "FR"),
    CountryData(name: "India", dialCode: "+91", code: "IN"),
    CountryData(name: "Nigeria", dialCode: "+234", code: "NG"),
    CountryData(name: "South Africa", dialCode: "+27", code: "ZA"),
    CountryData(name: "Japan", dialCode: "+81", code: "JP"),
    CountryData(name: "China", dialCode: "+86", code: "CN"),
    CountryData(name: "Brazil", dialCode: "+55", code: "BR"),
    CountryData(name: "Mexico", dialCode: "+52", code: "MX"),
    CountryData(name: "Spain", dialCode: "+34", code: "ES"),
    CountryData(name: "Italy", dialCode: "+39", code: "IT"),
  ]

  private var filteredCountries: [CountryData] {
    if let allowedCountries = allowedCountries {
      return allCountries.filter { allowedCountries.contains($0.code) }
    }
    return allCountries
  }

  public var body: some View {
    Menu {
      ForEach(filteredCountries, id: \.code) { country in
        Button {
          selectedCountry = country
        } label: {
          Text("\(country.flag) \(country.name) (\(country.dialCode))")
        }
        .accessibilityIdentifier("country-option-\(country.code)")
      }
    } label: {
      HStack(spacing: 4) {
        Text(selectedCountry.flag)
          .font(.title3)
        Text(selectedCountry.dialCode)
          .font(.body)
          .foregroundStyle(.primary)
        Image(systemName: "chevron.down")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .accessibilityIdentifier("country-selector")
    .disabled(!enabled)
  }
}
