//
//  GraphQLQuery.swift
//  
//
//  Created by Tomasz Kucharski on 01/04/2021.
//

import Foundation

public class GraphQLQuery {
    
    static let defaultIndent = 2
    private var from: String = ""
    private var arguments: [GraphQLArgument] = []
    private var fields: [String] = []
    private var subQueries: [GraphQLQuery] = []
    private var inlineFragments: [OptionalGraphQLFields] = []
    
    init() {
    }
    
    @discardableResult
    func from(_ from: String) -> GraphQLQuery {
        self.from = from
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
        self.subQueries.append(subQuery)
        return self
    }
    
    @discardableResult
    func add(subQueries: [GraphQLQuery]) -> GraphQLQuery {
        self.subQueries += subQueries
        return self
    }
    
    @discardableResult
    func select(_ onQuery: OptionalGraphQLFields) -> GraphQLQuery {
        self.inlineFragments.append(onQuery)
        return self
    }
    
    func build() throws -> String {
        return try self.build(0)
    }
    
    private func build(_ indent: Int = GraphQLQuery.defaultIndent) throws -> String {
        
        var query = self.makeIndents(indent)
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
