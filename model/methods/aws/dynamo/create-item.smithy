$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#integration

@integration(
    type: "aws"
    httpMethod: "POST"
    uri: "arn:aws:apigateway:${AWS::Region}:dynamodb:action/UpdateItem"
    credentials: "${ApiExecutionRole.Arn}"
    passThroughBehavior: "never"
    requestTemplates: {
        "application/json": """
        #set($ttl = $context.requestTimeEpoch / 1000 + 15552000)
        {
            "TableName": "$stageVariables.proxyTableName",
            "Key": { "itemId": { "S": "$context.extendedRequestId" } },
            "ConditionExpression": "attribute_not_exists(itemId)"
            "UpdateExpression": "SET #count = if_not_exists(#count, :start) + :inc, #createdAt = :timestamp, #lastModifiedAt = :timestamp, #ttl = :ttl",
            "ExpressionAttributeValues": { ":inc": { "N": "1" }, ":start": { "N": "0" }, ":timestamp": { "S": "$context.requestTime" }, ":ttl": { "N": "$ttl" } },
            "ExpressionAttributeNames": { "#count": "count", "#createdAt": "createdAt", "#lastModifiedAt": "lastModifiedAt", "#ttl": "expiresAt" },
            "ReturnValues": "ALL_NEW"
        }
        """
    },
    responses: {
        default: {
            statusCode: "200"
            responseTemplates: {
                "application/json": """
                #set($attributes=$input.path('$').Attributes)
                #set($context.responseOverride.header.itemId = "$attributes.itemId.S")
                {
                    "itemId": "$attributes.itemId.S",
                    "count": $attributes.count.N,
                    "createdAt": $attributes.createdAt.N,
                    "lastModifiedAt": $attributes.lastModifiedAt.N,
                    "expiresAt": $attributes.expiresAt.N
                }
                """
            }
        }
        "400": {
            statusCode: "400"
            responseTemplates: {
                "application/json": "{\"message\": \"Specified key already exists in the table!\"}"
            }
            responseParameters: {
                "method.response.header.x-amzn-ErrorType": "'BadRequestException'",
                "method.response.header.Access-Control-Allow-Headers": "'*'"
            }
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
@examples([
    {
        title: "example create operation"
        output: {
            itemId: "SYHzdEszvHcEiwA="
            count: 1
            createdAt: 1715195898
            lastModifiedAt: 1715195898
            expiresAt: 1715195898
        }
    }
])
@documentation("Creates an item in the table.")
@http(code: 200, method: "POST", uri: "/aws/items/dynamo")
operation CreateDynamoProxyItem with [BaseOperationErrors] {
    output := for DynamoProxyItem with [DynamoProxyItemElements] {}
}
