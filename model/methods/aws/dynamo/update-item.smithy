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
            "Key": { "itemId": { "S": "$method.request.path.itemId" } },
            "ConditionExpression": "attribute_exists(itemId)",
            "UpdateExpression": "SET #count = if_not_exists(#count, :start) + :inc, #lastModifiedAt = :timestamp, #ttl = :ttl",
            "ExpressionAttributeValues": { ":inc": { "N": "1" }, ":start": { "N": "0" }, ":timestamp": { "S": "$context.requestTime" }, ":ttl": { "N": "$ttl" } },
            "ExpressionAttributeNames": { "#count": "count", "#lastModifiedAt": "lastModifiedAt", "#ttl": "expiresAt" },
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
                    "createdAt": "$attributes.createdAt.S",
                    "lastModifiedAt": "$attributes.lastModifiedAt.S",
                    "expiresAt": $attributes.expiresAt.N
                }
                """
            }
        },
        "400": {
            statusCode: "404"
            responseTemplates: {
                "application/json": "{\"message\": \"No item with the specified id: $method.request.path.itemId!\"}"
            }
            responseParameters: {
                "method.response.header.x-amzn-ErrorType": "'NotFoundException'",
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
        title: "example update operation"
        input: { itemId: "SYHzdEszvHcEiwA=" }
        output: {
            itemId: "SYHzdEszvHcEiwA="
            count: 1
            createdAt: "11/May/2024:09:57:40 +0000"
            lastModifiedAt: "11/May/2024:09:57:40 +0000"
            expiresAt: 1715195898
        }
    }
])
@idempotent
@tags(["aws", "custom", "dynamo"])
@documentation("Updates an item with the specified id in the table.")
@http(code: 200, method: "PUT", uri: "/aws/items/dynamo/{itemId}")
operation UpdateDynamoItem with [BaseOperationErrors] {
    input := for DynamoItem {
        @required
        @httpLabel
        @documentation("Primary key for the item")
        $itemId
    }
    output := with [DynamoItemAttributes] {}
}
