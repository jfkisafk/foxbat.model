$version: "2"

namespace dev.stelo.foxbat

use aws.api#service
use aws.auth#sigv4
use aws.apigateway#requestValidator
use aws.protocols#restJson1

@title("Foxbat")
@service(
    sdkId: "foxbat"
    arnNamespace: "execute-api"
    endpointPrefix: "foxbat"
)
@requestValidator("full")
@cors(
    additionalAllowedHeaders: ["Content-Type"]
    additionalExposedHeaders: ["x-amzn-errortype", "x-amzn-requestid", "x-amzn-trace-id", "x-amz-apigw-id", "x-amzn-errormessage", "date", "x-amz-cf-id", "x-amzn-waf-action", "retry-after"]
)
@restJson1
@sigv4(name: "execute-api")
service Foxbat {
    version: "2018-05-10"
    operations: [Mock]
    resources: [DynamoProxyItem, S3ProxyItem]
}
