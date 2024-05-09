$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#integration

@integration(
    type: "aws"
    httpMethod: "POST"
    uri: "arn:aws:apigateway:${AWS::Region}:dynamodb:action/Scan"
    credentials: "${ApiExecutionRole.Arn}"
    passThroughBehavior: "never"
    requestTemplates: {
        "application/json": """
        {
            "TableName": "$stageVariables.statsTableName",
            "ConsistentRead": "true",
            #if ($method.request.querystring.size != '')
            "Limit": $method.request.querystring.size,
            #else
            "Limit": 50,
            #end
            #if ($method.request.querystring.nextToken != '')
            "ExclusiveStartKey": { "itemId": { "S": "$util.base64Decode($method.request.querystring.nextToken)" } },
            #end
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
                {
                    "items": [
                        #foreach($item in $root.Items) {
                        "itemId": "$item.itemId.S",
                        "count": $item.count.N,
                        "createdAt": $item.createdAt.N,
                        "lastModifiedAt": $item.lastModifiedAt.N,
                        "expiresAt": $item.expiresAt.N
                        }#if($foreach.hasNext),#end
                        #end
                    ]#if ($root.LastEvaluatedKey != ''),
                    "nextToken": "$util.base64Encode("$root.LastEvaluatedKey.itemId.S")"
                    #end
                }
                #else
                {
                    "message": "No items recorded yet!"
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
        title: "non-paginated example",
        output: {
            items: [
                {
                    itemId: "SYHzdEszvHcEiwA="
                    count: 1
                    createdAt: 1715195898
                    lastModifiedAt: 1715195898
                    expiresAt: 1715195898
                },
                {
                    itemId: "SYHzdEszvHcEiwA="
                    count: 1
                    createdAt: 1715195898
                    lastModifiedAt: 1715195898
                    expiresAt: 1715195898
                }
            ]
        }
    }
    {
        title: "paginated example",
        input: { size: 1, nextToken: "cHJha3ByYXN8YmFja3BsYW5lLW9wZXJhdGlvbnM=" }
        output: {
            items: [
                {
                    itemId: "SYHzdEszvHcEiwA="
                    count: 1
                    createdAt: 1715195898
                    lastModifiedAt: 1715195898
                    expiresAt: 1715195898
                }
            ],
            nextToken: "cHJha3ByYXN8Y2xvc2UtaXRlcm0yLXRtdXgtc2Vzc2lvbnM="
        }
    }
])
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "size")
@documentation("List all items in the table.")
@http(code: 200, method: "GET", uri: "/aws/items/dynamo")
operation ListDynamoProxyItems with [BaseOperationErrors] {
    input :=  {
        @documentation("Maximum page size for paginated results")
        @httpQuery("size")
        size: PageSize

        @documentation("Token for the next page in paginated results")
        @httpQuery("nextToken")
        nextToken: NonEmptyString
    },
    output := {
        @required
        @documentation("Item list scanned from the table")
        items: DynamoProxyItemList,

        @documentation("Token for the next page in paginated results")
        nextToken: NonEmptyString
    }
}
