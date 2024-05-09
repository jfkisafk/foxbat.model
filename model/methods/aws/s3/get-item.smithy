$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#integration

@integration(
    type: "aws"
    httpMethod: "GET"
    uri: "arn:aws:apigateway:${AWS::Region}:s3:path/${Bucket}/{key}"
    credentials: "${ApiExecutionRole.Arn}"
    requestParameters: {
        "integration.request.path.key": "method.request.path.key",
        "integration.request.querystring.versionId": "method.request.querystring.versionId"
    },
    responses: {
        default: {
            statusCode: "200"
        }
        "403": {
            statusCode: "403"
            responseTemplates: {
                "application/json": "{\"message\": \"User does not have access to the resource.\"}"
            }
            responseParameters: {
                "method.response.header.x-amzn-ErrorType": "'ForbiddenException'",
                "method.response.header.Access-Control-Allow-Headers": "'*'"
            }
        }
        "404": {
            statusCode: "404"
            responseTemplates: {
                "application/json": "{\"message\": \"The requested resource was not found.\"}"
            }
            responseParameters: {
                "method.response.header.x-amzn-ErrorType": "'NotFoundException'",
                "method.response.header.Access-Control-Allow-Headers": "'*'"
            }
        }
        "429": {
            statusCode: "429"
            responseTemplates: {
                "application/json": "{\"message\": \"Rate limit exceeded for the operation (throttled).\"}",
            }
            responseParameters: {
                "method.response.header.x-amzn-ErrorType": "'ThrottledException'",
                "method.response.header.Access-Control-Allow-Headers": "'*'"
            }
        }
        "5\\d{2}": {
            statusCode: "500"
            responseTemplates: {
                "application/json": "{\"message\": \"Internal Server Error. Please contact the service team with the request parameters and these response header values: date, x-amzn-requestid and x-amzn-errortype\"}"
            }
            responseParameters: {
                "method.response.header.x-amzn-ErrorType": "'InternalServerErrorException'",
                "method.response.header.Access-Control-Allow-Headers": "'*'"
            }
        }
    }
)
@readonly
@examples([
    {
        title: "Non-versioned example",
        input: { key: "test.json" },
        output: { content: "{\"abc\": 123}" }
    },
    {
        title: "Versioned example",
        input: { key: "test.json", version: "v1" },
        output: { content: "{\"abc\": 456}" }
    }
])
@http(code: 200, method: "GET", uri: "/aws/items/s3/{key}")
@documentation("Gets the item from S3 bucket")
operation GetS3Item with [BaseOperationErrors] {
    input := for S3Item with [S3ItemKey] {
        @httpQuery("version")
        @documentation("Version for the object")
        $version
    },
    output := with [S3ItemContent] {}
}

