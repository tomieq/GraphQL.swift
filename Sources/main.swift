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
        .select(GraphQLQuery()
            .from("fullTextCursor")
            .argument("types", value: ["Site"])
            .argument("rsql", value: "id=in=(37318945)")
            .select(GraphQLQuery()
                .from("edges")
                .select(GraphQLQuery()
                    .from("node")
                    .select("id")
                    .select(OptionalGraphQLFields(whenResponseIs: "Location")
                        .select("name")
                        .select(GraphQLQuery()
                            .from("attachments")
                            .select(["name", "fileName", "fileExtension"])
                        )
                    )
                )
            )
        )
    print(try query.build())
} catch {
}
