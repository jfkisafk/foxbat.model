$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#mockIntegration

@mockIntegration(
    passThroughBehavior: "never"
    requestTemplates: {
        "application/json": "{\"statusCode\": 200}"
    }
    responses: {
        default: {
            statusCode: "200"
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
        title: "example"
        input: { query: "test" }
        output: { query: "test", extendedRequestId: "SYHzdEszvHcEiwA=" }
    }
])
@documentation("Mock operation")
operation Mock with [BaseOperationErrors] {
    input := with [MockQuery] {
        @required
        @httpQuery("query")
        @documentation("Query for the mock call")
        query: NonEmptyString
    }
    output := with [MockQuery] {
        @required
        @documentation("Extended RequestId for the mock call")
        extendedRequestId: NonEmptyString
    }
}

@mixin
structure MockQuery {
    @required
    @documentation("Query for the mock call")
    query: NonEmptyString
}

