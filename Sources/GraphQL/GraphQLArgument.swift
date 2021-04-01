//
//  GraphQLArgument.swift
//  
//
//  Created by Tomasz Kucharski on 01/04/2021.
//

import Foundation

struct GraphQLArgument {
    let key: String
    let value: Any

    public init(key: String, value: Any) {
      self.key = key
      self.value = value
    }

    func build() -> String {
      return "\(key): \(value)"
    }
}
