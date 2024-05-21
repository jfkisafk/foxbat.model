$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#integration

@integration(
    type: "http"
    httpMethod: "GET"
    uri: "https://www.raycast.com/favicon-production.png"
    responses: {
        default: {
            statusCode: "200"
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
@auth([])
@readonly
@tags(["http", "custom", "favicon"])
@http(code: 200, method: "GET", uri: "/favicon.ico")
@documentation("Gets the favicon from Raycast website.")
operation GetFavicon with [BaseOperationErrors] {
    output := {
        @httpPayload
        favicon: Favicon
    }
}

@mediaType("image/*")
blob Favicon

