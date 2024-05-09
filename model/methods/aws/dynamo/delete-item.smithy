$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#integration

@integration(
    type: "aws"
    httpMethod: "POST"
    uri: "arn:aws:apigateway:${AWS::Region}:dynamodb:action/DeleteItem"
    credentials: "${ApiExecutionRole.Arn}"
    passThroughBehavior: "never"
    requestTemplates: {
        "application/json": """
        {
            "TableName": "$stageVariables.proxyTableName",
            "Key": { "itemId": { "S": "$method.request.path.itemId" } },
            "ConditionExpression": "attribute_exists(itemId)"
            "ReturnValues": "ALL_OLD"
        }
        """
    },
    responses: {
        default: {
            statusCode: "200",
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
        title: "example delete operation"
        input: { itemId: "SYHzdEszvHcEiwA=" }
        output: {
            itemId: "SYHzdEszvHcEiwA="
            count: 1
            createdAt: 1715195898
            lastModifiedAt: 1715195898
            expiresAt: 1715195898
        }
    }
])
@idempotent
@documentation("Deletes the item with the specified id.")
@http(code: 200, method: "DELETE", uri: "/aws/items/dynamo/{itemId}")
operation DeleteDynamoProxyItem with [BaseOperationErrors] {
    input := for DynamoProxyItem {
        @required
        @httpLabel
        @documentation("Primary key for the item")
        $itemId
    }
    output := for DynamoProxyItem with [DynamoProxyItemElements] {}
}
