//
//  GraphQLQuery.swift
//  
//
//  Created by Tomasz Kucharski on 01/04/2021.
//

import Foundation

public enum GraphQLQueryType: String {
    case shorthand
    case query
    case mutation
    case subscription
}

public class GraphQLQuery {
    
    static let defaultIndent = 2
    private let type: GraphQLQueryType
    private var from: String = ""
    private var variable: [GraphQLArgument] = []
    private var arguments: [GraphQLArgument] = []
    private var fields: [String] = []
    private var subQueries: [GraphQLQuery] = []
    private var inlineFragments: [OptionalGraphQLFields] = []

    var isValid: Bool {
        return !(self.fields.isEmpty && self.subQueries.isEmpty && self.inlineFragments.isEmpty)
    }

    init(_ type: GraphQLQueryType = .shorthand) {
        self.type = type
    }
    
    @discardableResult
    func from(_ from: String) -> GraphQLQuery {
        self.from = from
        return self
    }

    @discardableResult
    func from(_ from: String, alias: String) -> GraphQLQuery {
        self.from = "\(alias): \(from)"
        return self
    }

    @discardableResult
    func argument(_ argument: GraphQLArgument) -> GraphQLQuery {
        self.arguments.append(argument)
        return self
    }

    @discardableResult
    func arguments(_ arguments: [GraphQLArgument]) -> GraphQLQuery {
      self.arguments += arguments
      return self
    }

    @discardableResult
    func variable(_ key: String, type: String, default defaultValue: Any? = nil) -> GraphQLQuery {
        self.arguments.append(GraphQLArgument(key: "$\(key)", value: "\(type)\(defaultValue == nil ? "" : " = \(defaultValue!)")"))
        return self
    }

    @discardableResult
    func argument(_ key: String, value: Any) -> GraphQLQuery {
        self.arguments.append(GraphQLArgument(key: key, value: value))
        return self
    }
    
    @discardableResult
    func select(_ field: String) -> GraphQLQuery {
        self.fields.append(field)
        return self
    }
    
    @discardableResult
    func select(_ fields: [String]) -> GraphQLQuery {
        self.fields += fields
        return self
    }
    
    @discardableResult
    func select(_ subQuery: GraphQLQuery) -> GraphQLQuery {
        guard subQuery.isValid else { return self }

        if let inlineQuery = subQuery as? OptionalGraphQLFields {
            if let existingSubquery = (self.inlineFragments.first{ $0.objectType == inlineQuery.objectType }) {
                existingSubquery.merge(inlineQuery)
            } else {
                self.inlineFragments.append(inlineQuery)
            }
            return self
        }

        if let existingSubquery = (self.subQueries.first{ $0.from == subQuery.from }) {
            existingSubquery.merge(subQuery)
        } else {
            self.subQueries.append(subQuery)
        }
        return self
    }
    
    @discardableResult
    func select(_ subQueries: [GraphQLQuery]) -> GraphQLQuery {
        subQueries.forEach { self.select($0) }
        return self
    }
    
    @discardableResult
    func select(path: String, separator: String.Element = ".") -> GraphQLQuery {
        guard path.contains(separator) else {
            return self.select(path)
        }
        var nestedQuery: GraphQLQuery = self
        let components = path.split(separator: separator)
        for i in (0...components.count-2) {
            let from = "\(components[i])"
            if let subquery = (nestedQuery.subQueries.filter{ $0.from == from }.first) {
                nestedQuery = subquery
            } else {
                let subquery = GraphQLQuery().from(from)
                nestedQuery.subQueries.append(subquery)
                nestedQuery = subquery
            }
        }
        nestedQuery.select("\(components.last ?? "-")")
        return self
    }
    
    private func merge(_ other: GraphQLQuery) {
        self.select(other.fields)
        self.select(other.subQueries)
        self.inlineFragments += other.inlineFragments
    }
    
    func build() throws -> String {
        return try self.build(0)
    }
    
    private func build(_ indent: Int = GraphQLQuery.defaultIndent) throws -> String {
        
        var query = self.makeIndents(indent)
        switch self.type {
        case .shorthand:
            break
        default:
            query.append("\(self.type.rawValue) ")
        }
        if let inlineFragment = self as? OptionalGraphQLFields {
            query.append("... on \(inlineFragment.objectType)")
        } else {
            query.append(self.from)
        }
        if !self.arguments.isEmpty {
            query.append("(\(self.arguments.map{ $0.build() }.joined(separator: ", "))) ")
        } else {
            query.append(" ")
        }
        
        let addParenthesis = !self.fields.isEmpty || !self.subQueries.isEmpty || !self.inlineFragments.isEmpty
        if addParenthesis {
            query.append("{")
        }
        let innerIndent = indent + GraphQLQuery.defaultIndent
        self.fields.forEach { field in
            query.append("\n\(self.makeIndents(innerIndent))\(field)")
        }
        if !self.subQueries.isEmpty {
            try self.subQueries.forEach { subquery in
                query.append("\n\(try subquery.build(innerIndent))")
            }
        }
        if !self.inlineFragments.isEmpty {
            try self.inlineFragments.forEach { inlineFragment in
                query.append("\n\(try inlineFragment.build(innerIndent))")
            }
        }
        if addParenthesis {
            query.append("\n\(self.makeIndents(indent))}")
        }
        return query
    }
    
    private func makeIndents(_ depth: Int) -> String {
        guard depth > 0 else { return "" }
        return (0...depth).map{_ in " "}.joined()
    }
}

public class OptionalGraphQLFields: GraphQLQuery {
    
    fileprivate let objectType: String
    
    init(whenResponseIs objectType: String) {
        self.objectType = objectType
        super.init()
    }
}

extension GraphQLQuery: Comparable {
    public static func == (lhs: GraphQLQuery, rhs: GraphQLQuery) -> Bool {
        return lhs.from == rhs.from && lhs.fields.sorted() == rhs.fields.sorted()
    }
    
    public static func < (lhs: GraphQLQuery, rhs: GraphQLQuery) -> Bool {
        return lhs.from < rhs.from
    }
    
}
