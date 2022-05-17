# GraphQL.swift

GraphQL.swift is a lightweight library for building GraphQL queries.
 - removes duplicated fields
 - support for subqueries
 - support for inline fragments
 - subquery merging
 - support for arguments
 - alias support

Example usage:
```
let query = GraphQLQuery(.query)
            .select("id")
            .select("name")
```
Will produce:
```
query  {
   id
   name
}
```

### Subqueries
Code:
```
let query = GraphQLQuery(.query)
    .select("id")
    .select(GraphQLQuery()
                .from("device")
                .select("name")
                .select("uuid")
    )
```
Will produce:
```
query  {
   id
   device {
     name
     uuid
   }
}
```
### Attributes can be selected in bulk with array or variadic parameter
```
let query = GraphQLQuery(.query)
    .select("id", "color", "brand")
    .select(["language", "fontSize", "fontFamily"])
```
### Inline fragments
Code:
```
let query = GraphQLQuery(.query)
    .select("id")
    .select(
        OptionalGraphQLFields(whenResponseIs: "Modem")
            .select("serialNumber")
            .select("MAC")
    )
```
Will produce:
```
query  {
   id
   ... on Modem {
     MAC
     serialNumber
   }
}
```
### Nested subqueries by path
Code:
```
let query = GraphQLQuery(.query)
    .select(path: "device.brand.name", separator: ".")
```
Will produce:
```
query  {
   device {
     brand {
       name
     }
   }
}
```
### Merging subqueries
If your query is build in a few stages and each stage adds the same subquery, the output is merged.
```
let query = GraphQLQuery(.query)
    .select(GraphQLQuery().from("model").select("id"))
    .select(GraphQLQuery().from("model").select("name"))
```
Will produce:
```
query  {
   model {
     id
     name
   }
}
```
The same with inline fragments:
```
let query = GraphQLQuery(.query)
    .select(OptionalGraphQLFields(whenResponseIs: "GFX").select("id"))
    .select(OptionalGraphQLFields(whenResponseIs: "GFX").select("name"))
```
Output:
```
query  {
   ... on GFX {
     id
     name
   }
}
```
### Support for arguments
```
let query = GraphQLQuery(.query)
    .select("id")
    .select(GraphQLQuery()
        .from("logicalFunctions")
        .argument("rsql", value: "type==Car")
        .select("name"))
```
Output:
```
query  {
   id
   logicalFunctions(rsql: "type==Car") {
     name
   }
}
```
### Alias support
```
        let query = GraphQLQuery(.query)
            .select("id")
            .select(GraphQLQuery()
                .from("logicalFunctions", alias: "functions")
                .select("name"))
```
Will produce:
```
query  {
   id
   functions: logicalFunctions {
     name
   }
}
```
