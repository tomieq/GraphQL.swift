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
    
    func testSubQuery() throws {
        let query = GraphQLQuery(.query)
            .select("id")
            .select(GraphQLQuery()
                        .from("device")
                        .select("name")
                        .select("uuid")
            )
        
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { id device { name uuid } }".condenseWhitespace())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testMultipleFields() throws {
        let query = GraphQLQuery(.query)
            .select(["id", "color", "brand"])
        
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { brand color id }".condenseWhitespace())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testMultipleFieldsDuplicated() throws {
        let query = GraphQLQuery(.query)
            .select(["id", "color", "id", "brand"])
        
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { brand color id }".condenseWhitespace())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testInlineFragments() throws {
        let query = GraphQLQuery(.query)
            .select("id")
            .select(OptionalGraphQLFields(whenResponseIs: "Modem").select("id"))
        
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { id ... on Modem { id } }".condenseWhitespace())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testPathSelect() throws {
        let query = GraphQLQuery(.query)
            .select(path: "device.brand.name", separator: ".")
        
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { device { brand { name } } }".condenseWhitespace())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testSubqueryMerging() throws {
        let query = GraphQLQuery(.query)
            .select(GraphQLQuery().from("model").select("id"))
            .select(GraphQLQuery().from("model").select("name"))
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { model { id name } }".condenseWhitespace())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testInlineFragmentsMerging() throws {
        let query = GraphQLQuery(.query)
            .select(OptionalGraphQLFields(whenResponseIs: "GFX").select("id"))
            .select(OptionalGraphQLFields(whenResponseIs: "GFX").select("name"))
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { ... on GFX { id name } }".condenseWhitespace())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testSubQueryArgument() throws {
        let query = GraphQLQuery(.query)
            .select("id")
            .select(GraphQLQuery()
                        .from("logicalFunctions")
                        .argument("rsql", value: "type==Car")
                        .select("name"))
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { id  logicalFunctions(rsql: \"type==Car\") { name } }".condenseWhitespace())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFromAlias() throws {
        let query = GraphQLQuery(.query)
            .select("id")
            .select(GraphQLQuery()
                        .from("logicalFunctions", alias: "functions")
                        .argument("rsql", value: "type==Car")
                        .select("name"))
        do {
            let output = try query.build()
            XCTAssertEqual(output.condenseWhitespace(), "query { id  functions: logicalFunctions(rsql: \"type==Car\") { name } }".condenseWhitespace())
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
