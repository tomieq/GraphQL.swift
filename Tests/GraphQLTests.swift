//
//  GraphQLTests.swift
//  
//
//  Created by Tomasz Kucharski on 25/01/2022.
//

import Foundation
import XCTest
@testable import GraphQL

final class GraphQLTests: XCTestCase {
    
    func testBasicQuery() throws {
        let query = GraphQLQuery(.query)
            .select("id")
            .select("name")
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { id name }".condenseWhitespace())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testRemovingDuplicatedFields() throws {
        let query = GraphQLQuery(.query)
            .select("id")
            .select("id")
            .select("name")
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { id name }".condenseWhitespace())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

fileprivate extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
