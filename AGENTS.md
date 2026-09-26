# AGENTS.md

This file provides guidance to coding agents working with code in this repository.

This repo is a Smithy IDL model of Foxbat, a sample API Gateway REST API with proxy, custom AWS, and mock integrations. The build produces an OpenAPI document with API Gateway extensions. It has no Java sources and no tests.

## Commands

```sh
./gradlew build                        # format, validate, build projections, jar
./gradlew smithyBuild                  # just regenerate the OpenAPI output
./gradlew smithyFormat --rerun build   # force the formatter after reverting model files
```

`build` runs `smithy format`, which rewrites `model/**/*.smithy` in place. Gradle can mark `smithyFormat` up to date and skip it even after model files change (for example, after a `git checkout`). Use `--rerun` in that case.

The build writes its output to `build/smithyprojections/foxbat.model/source/openapi/Foxbat.openapi.json`.

## Build setup

`build.gradle.kts` uses the `software.amazon.smithy.gradle.smithy-jar` 1.x plugin. Plugin 0.x doesn't work on Gradle 9. The OpenAPI converter (`smithy-openapi`) is a `smithyBuild` dependency. The Smithy traits and the API Gateway OpenAPI mapper are `implementation` dependencies. The plugin reads `model/` by default.

`smithy-build.json` configures the `openapi` plugin:
- `apiGatewayDefaults: 2023-08-11`
- `syncCorsPreflightIntegration`
- `jsonAdd`, which injects the account-level API Gateway config: every `x-amazon-apigateway-gateway-responses` entry (with CORS headers and error-type headers), the endpoint configuration that disables the execute-api endpoint, and the resource policy.

Change gateway responses and the resource policy in `smithy-build.json`, not in the model.

## Model layout

- `model/main.smithy`: the `Foxbat` service. It sets restJson1, sigv4, CORS, a `full` request validator, and binds all resources and top-level operations.
- `model/resources/`: resource shapes (`DynamoItem`, `S3Item`, `PetStore`) and mixins for their shared members.
- `model/methods/`: one operation per file, grouped by integration type. `aws/dynamo` and `aws/s3` use `type: "aws"` service integrations. `http/petstore` uses HTTP proxy integrations. `mock.smithy` uses a mock integration.
- `model/exceptions.smithy`: error structures and the `BaseOperationErrors` operation mixin. Operations include it with `with [BaseOperationErrors]`.

Each operation declares its API Gateway `@integration` inline. It also maps backend status codes to method responses, and sets the `x-amzn-ErrorType` header to match the error structures in `exceptions.smithy`. When you add an operation, copy the integration from an existing operation of the same integration type.

Integration URIs and credentials contain CloudFormation substitution placeholders: `${AWS::Region}`, `${Bucket}`, and `${ApiExecutionRole.Arn}`. The generated OpenAPI keeps them as literal text. A CloudFormation template outside this repo is expected to resolve them, so don't replace them with real values.

The model validates with no warnings. Keep it that way. If a validator flags a false positive, suppress it on that shape with `@suppress` and add a comment explaining why.