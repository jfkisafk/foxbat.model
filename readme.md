# foxbat.model

This is a [Smithy](https://smithy.io) model of Foxbat, a sample Amazon API Gateway REST API. It demonstrates mock, HTTP proxy, and AWS service integrations. The build turns the model into an OpenAPI document with the `x-amazon-apigateway-*` extensions, ready for import into API Gateway.

## Build

This requires JDK 17 or later.

```sh
./gradlew build
```

The build formats and validates the model, then writes the OpenAPI document to:

```
build/smithyprojections/foxbat.model/source/openapi/Foxbat.openapi.json
```

## Operations

| Method | Path | Integration | Backend |
| --- | --- | --- | --- |
| GET | `/mock` | mock | Echoes the request ID and the `query` parameter |
| GET | `/favicon.ico` | HTTP | Proxies a remote PNG |
| GET | `/pets` | HTTP | PetStore demo endpoint |
| GET | `/pets/{petId}` | HTTP | PetStore demo endpoint |
| GET | `/aws/items/s3/{key}` | AWS | S3 `GetObject` |
| PUT | `/aws/items/s3/{key}` | AWS | S3 `PutObject` |
| GET | `/aws/items/dynamo` | AWS | DynamoDB `Scan` |
| POST | `/aws/items/dynamo` | AWS | DynamoDB `UpdateItem` |
| GET | `/aws/items/dynamo/{itemId}` | AWS | DynamoDB `Query` |
| PUT | `/aws/items/dynamo/{itemId}` | AWS | DynamoDB `UpdateItem` |
| DELETE | `/aws/items/dynamo/{itemId}` | AWS | DynamoDB `DeleteItem` |

Requests to all operations are signed with SigV4 (`execute-api`). API Gateway validates the request body and parameters before calling the integration. Error responses set an `x-amzn-ErrorType` header that names one of the error shapes in `model/exceptions.smithy`.

## Deploying

The AWS integrations reference CloudFormation values that the generated document leaves unresolved:

- `${AWS::Region}`
- `${Bucket}`: the S3 bucket that backs `/aws/items/s3`
- `${ApiExecutionRole.Arn}`: the IAM role API Gateway assumes to call S3 and DynamoDB

To deploy, resolve these values with `Fn::Sub`, for example by embedding the document as the `Body` of an `AWS::ApiGateway::RestApi` resource.

The document also includes a resource policy. That policy restricts `/favicon*` to one source IP. It also disables the default `execute-api` endpoint, so the API needs a custom domain. These settings, along with the gateway response templates, come from the `jsonAdd` block in `smithy-build.json`.

## License

[MIT](license.md)