//
//  GraphQLQuery.swift
//  
//
//  Created by Tomasz Kucharski on 01/04/2021.
//

import Foundation

struct GraphQLQuery {
    
    static let defaultIndent = 2
    var from: String
    
    func build(_ indent: Int = GraphQLQuery.defaultIndent) throws -> String {
        var query = self.makeIndents(indent)
        query.append(self.from)
        query.append(" {\n")
        query.append("}")
        return query
    }
    
    private func makeIndents(_ depth: Int) -> String {
        guard depth > 0 else { return "" }
        return (0...depth).map{_ in " "}.joined()
    }
}
