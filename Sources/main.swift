//
//  main.swift
//  
//
//  Created by Tomasz Kucharski on 01/04/2021.
//

import Foundation

do {
    
    let query = GraphQLQuery()
        .from("query")
        .argument("$types", value: ["Site"])
        .argument("$rsql", value: "id=in=(37318945)")
        .subQuery(GraphQLQuery()
            .from("fullTextCursor")
            .argument("types", value: ["Site"])
            .argument("rsql", value: "id=in=(37318945)")
            .subQuery(GraphQLQuery()
                .from("edges")
                .subQuery(GraphQLQuery()
                    .from("node")
                    .field("id")
                    .onQuery(GraphQLQuery()
                        .from("Location")
                        .field("name")
                        .subQuery(GraphQLQuery()
                            .from("attachments")
                            .fields(["name", "fileName", "fileExtension"])
                        )
                    )
                )
            )
        )
    print(try query.build())
} catch {
}
