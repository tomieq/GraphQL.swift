//
//  GraphQLQuery.swift
//  
//
//  Created by Tomasz Kucharski on 01/04/2021.
//

import Foundation

class GraphQLQuery {
    
    static let defaultIndent = 2
    private let from: String
    private var arguments: [GraphQLArgument] = []
    private var fields: [String] = []
    private var subQueries: [GraphQLQuery] = []
    private var onQueries: [GraphQLQuery] = []
    
    init(from: String) {
        self.from = from
    }
    
    @discardableResult
    func argument(_ argument: GraphQLArgument) -> GraphQLQuery {
        self.arguments.append(argument)
        return self
    }
    
    @discardableResult
    func add(arguments: [GraphQLArgument]) -> GraphQLQuery {
      self.arguments += arguments
      return self
    }
    
    @discardableResult
    func argument(_ key: String, value: Any) -> GraphQLQuery {
        self.arguments.append(GraphQLArgument(key: key, value: value))
        return self
    }
    
    @discardableResult
    func field(_ field: String) -> GraphQLQuery {
        self.fields.append(field)
        return self
    }
    
    @discardableResult
    func fields(_ fields: [String]) -> GraphQLQuery {
        self.fields += fields
        return self
    }
    
    @discardableResult
    func subQuery(_ subQuery: GraphQLQuery) -> GraphQLQuery {
        self.subQueries.append(subQuery)
        return self
    }
    
    @discardableResult
    func add(subQueries: [GraphQLQuery]) -> GraphQLQuery {
        self.subQueries += subQueries
        return self
    }
    
    @discardableResult
    func onQuery(_ onQuery: GraphQLQuery) -> GraphQLQuery {
        self.onQueries.append(onQuery)
        return self
    }
    
    @discardableResult
    func add(onQueries: [GraphQLQuery]) -> GraphQLQuery {
        self.onQueries += onQueries
        return self
    }
    
    func build() throws -> String {
        return try self.build(0)
    }
    
    private func build(_ indent: Int = GraphQLQuery.defaultIndent, isOnQuery: Bool = false) throws -> String {
        
        var query = self.makeIndents(indent)
        if isOnQuery {
            query.append("... on ")
        }
        query.append(self.from)
        if !self.arguments.isEmpty {
            query.append(" (\(self.arguments.map{ $0.build() }.joined(separator: ", ")))")
        }
        query.append(" {")
        let innerIndent = indent + GraphQLQuery.defaultIndent
        self.fields.forEach { field in
            query.append("\n\(self.makeIndents(innerIndent))\(field)")
        }
        if !self.subQueries.isEmpty {
            try self.subQueries.forEach { subquery in
                query.append("\n\(try subquery.build(innerIndent))")
            }
        }
        if !self.onQueries.isEmpty {
            try self.onQueries.forEach { onQuery in
                query.append("\n\(try onQuery.build(innerIndent, isOnQuery: true))")
            }
        }
        query.append("\n\(self.makeIndents(indent))}")
        return query
    }
    
    private func makeIndents(_ depth: Int) -> String {
        guard depth > 0 else { return "" }
        return (0...depth).map{_ in " "}.joined()
    }
}
