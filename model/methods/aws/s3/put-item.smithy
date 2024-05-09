$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#integration

@integration(
    type: "aws"
    httpMethod: "PUT"
    uri: "arn:aws:apigateway:${AWS::Region}:s3:path/${Bucket}/{key}"
    credentials: "${ApiExecutionRole.Arn}"
    requestParameters: {
        "integration.request.path.key": "method.request.path.key",
        "integration.request.header.Content-Type": "method.request.header.Content-Type"
    },
    responses: {
        default: {
            statusCode: "200"
        }
        "429": {
            statusCode: "429"
            responseTemplates: {
                "application/json": "{\"message\": \"Rate limit exceeded for the operation (throttled).\"}"
            }
            responseParameters: {
                "method.response.header.x-amzn-ErrorType": "'ThrottledException'",
                "method.response.header.Access-Control-Allow-Headers": "'*'"
            }
        }
        "4\\d{2}|5\\d{2}": {
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
@idempotent
@examples([
    {
        title: "No content example",
        input: { key: "test.json", contentType: "application/json" }
    },
    {
        title: "Content example",
        input: { key: "test.json", contentType: "application/json", content: "{\"abc\": 456}" }
    }
])
@documentation("Puts the item in the S3 bucket")
@http(code: 200, method: "PUT", uri: "/aws/items/s3/{key}")
operation PutS3Item with [BaseOperationErrors] {
    input := for S3Item with [S3ItemKey, S3ItemContent] {
        @required
        @httpHeader("Content-Type")
        @documentation("Item mime type")
        $contentType
    }
}
