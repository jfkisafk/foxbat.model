$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#integration

@integration(
    type: "aws"
    httpMethod: "POST"
    uri: "arn:aws:apigateway:${AWS::Region}:dynamodb:action/Query"
    credentials: "${ApiExecutionRole.Arn}"
    passThroughBehavior: "never"
    requestTemplates: {
        "application/json": """
        {
            "TableName": "$stageVariables.proxyTableName",
            "ConsistentRead": "true",
            "Limit": 1,
            "KeyConditionExpression": "itemId = :itemId",
            "ExpressionAttributeValues": { ":itemId": { "S": "$method.request.path.itemId" } }
        }
        """
    },
    responses: {
        default: {
            statusCode: "200",
            responseTemplates: {
                "application/json": """
                #set($root=$input.path('$'))
                #if($root.Count > 0)
                #set($item=$root.Items[0])
                {
                    "itemId": "$item.itemId.S",
                    "count": $item.count.N,
                    "createdAt": $item.createdAt.N,
                    "lastModifiedAt": $item.lastModifiedAt.N,
                    "expiresAt": $item.expiresAt.N
                }
                #else
                {
                    "message": "No item for id: $method.request.path.itemId!"
                }
                #set($context.responseOverride.status = 404)
                #set($context.responseOverride.header.x-amzn-ErrorType = 'NotFoundException')
                #set($context.responseOverride.header.Access-Control-Allow-Headers = '*')
                #end
                """
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
@readonly
@examples([
    {
        title: "example get operation"
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
@documentation("Gets the item with the specified id.")
@http(code: 200, method: "GET", uri: "/aws/items/dynamo/{itemId}")
operation GetDynamoItem with [BaseOperationErrors] {
    input := for DynamoItem {
        @required
        @httpLabel
        @documentation("Primary key for the item")
        $itemId
    }
    output := with [DynamoItemAttributes] {}
}
