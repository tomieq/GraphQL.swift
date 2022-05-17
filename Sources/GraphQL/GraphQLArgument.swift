//
//  GraphQLArgument.swift
//
//
//  Created by Tomasz Kucharski on 01/04/2021.
//

import Foundation

public struct GraphQLArgument {
    let key: String
    let value: Any

    public init(key: String, value: Any) {
        self.key = key
        self.value = value
    }

    func build() -> String {
        if let value = value as? GraphQLRawString {
            return "\(self.key): \(value.string)"
        } else if let value = value as? String, let escaped = GraphQLEscapedString(value) {
            return "\(self.key): \(escaped)"
        } else if let value = value as? [String: Any] {
            return "\(self.key): \(GraphQLEscapedDictionary(value))"
        } else if let value = value as? [Any] {
            return "\(self.key): \(GraphQLEscapedArray(value))"
        }
        return "\(self.key): \(value)"
    }
}

/*
 Use GraphQLRawString when you want your String without quote signs
 */
public struct GraphQLRawString {
    let string: String

    init(_ string: String) {
        self.string = string
    }
}

struct GraphQLEscapedString: LosslessStringConvertible {
    var value: String

    init?(_ description: String) {
        self.value = description
    }

    var description: String {
        self.value
    }
}

struct GraphQLEscapedDictionary {
    let value: [String: Any]

    init(_ value: [String: Any]) {
        self.value = value
    }
}

struct GraphQLEscapedArray {
    let value: [Any]

    init(_ value: [Any]) {
        self.value = value
    }
}

extension DefaultStringInterpolation {
    mutating func appendInterpolation(repeat str: String, _ count: Int) {
        for _ in 0..<count {
            self.appendInterpolation(str)
        }
    }

    mutating func appendInterpolation(_ value: GraphQLEscapedString) {
        self.appendInterpolation(#""\#(self.escape(string: value.description))""#)
    }

    /// Escape strings according to https://facebook.github.io/graphql/#sec-String-Value
    /// - Parameter input: The string to escape
    /// - Returns: The escaped string
    private func escape(string input: String) -> String {
        var output = ""
        for scalar in input.unicodeScalars {
            switch scalar {
            case "\"":
                output.append("\\\"")
            case "\\":
                output.append("\\\\")
            case "\u{8}":
                output.append("\\b")
            case "\u{c}":
                output.append("\\f")
            case "\n":
                output.append("\\n")
            case "\r":
                output.append("\\r")
            case "\t":
                output.append("\\t")
            case UnicodeScalar(0x0)...UnicodeScalar(0xf), UnicodeScalar(0x10)...UnicodeScalar(0x1f):
                output.append(String(format: "\\u%04x", scalar.value))
            default:
                output.append(Character(scalar))
            }
        }

        return output
    }

    mutating func appendInterpolation(_ value: GraphQLEscapedDictionary) {
        let output = value.value.map { key, value in
            let serializedValue: String
            if let value = value as? String, let escapable = GraphQLEscapedString(value) {
                serializedValue = "\(escapable)"
            } else if let value = value as? [String: Any] {
                serializedValue = "\(GraphQLEscapedDictionary(value))"
            } else if let value = value as? [Any] {
                serializedValue = "\(GraphQLEscapedArray(value))"
            } else {
                serializedValue = "\(value)"
            }

            return "\(key): \(serializedValue)"
        }.joined(separator: ",")

        self.appendInterpolation("{\(output)}")
    }

    mutating func appendInterpolation(_ value: GraphQLEscapedArray) {
        let output = value.value.map { element in
            if let element = element as? String, let escapable = GraphQLEscapedString(element) {
                return "\(escapable)"
            } else if let element = element as? [String: Any] {
                return "\(GraphQLEscapedDictionary(element))"
            } else if let element = element as? [Any] {
                return "\(GraphQLEscapedArray(element))"
            }
            return "\(element)"
        }.joined(separator: ",")

        self.appendInterpolation("[\(output)]")
    }
}
