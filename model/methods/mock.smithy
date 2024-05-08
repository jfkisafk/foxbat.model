$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#mockIntegration

@mockIntegration(
    passThroughBehavior: "never",
    requestTemplates: {
        "application/json": "{\"statusCode\": 200}"
    },
    responses: {
        default: {
            statusCode: "200",
            responseTemplates: {
                "application/json": "{\"extendedRequestId\": \"$context.extendedRequestId\", \"query\": \"$input.params('query')\"}"
            }
        }
    }
)
@readonly
@http(code: 200, method: "GET", uri: "/mock")
@examples([
    {
        title: "example",
        input: { query: "test" },
        output: { query: "test", region: "us-west-2" }
    }
])
@documentation("Mock operation")
operation Mock with [BaseOperationErrors] {
    input := with [MockQuery] {
        @required
        @httpQuery("query")
        @documentation("Query for the mock call")
        query: NonEmptyString
    },
    output := with [MockQuery] {
        @required
        @documentation("AWS region for the mock call")
        region: NonEmptyString
    }
}

@mixin
structure MockQuery {
    @required
    @documentation("Query for the mock call")
    query: NonEmptyString
}

