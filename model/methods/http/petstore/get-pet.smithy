$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#integration

@integration(
    type: "http"
    httpMethod: "GET"
    uri: "http://petstore-demo-endpoint.execute-api.com/petstore/pets/{id}"
    requestParameters: { "integration.request.path.id": "method.request.path.petId" }
    responses: { default: { statusCode: "200" } }
)
@tags(["http", "custom", "petstore"])
@readonly
@examples([
    {
        title: "example - success"
        input: { petId: "7" }
        output: {
            id: 7
            type: "dog"
            price: 249.99
        }
    },
    {
        title: "example - error"
        input: { petId: "cat" }
        output: {
            errors: [
                {
                    key: "Pet2.type"
                    message: "Missing required field"
                },
                {
                    key: "Pet2.price"
                    message: "Missing required field"
                }
            ]
        }
    }
])
@documentation("Get a pet from execute-api petstore")
@http(code: 200, method: "GET", uri: "/pets/{petId}")
operation GetPet with [BaseOperationErrors] {
    input := for PetStore {
        @required
        @httpLabel
        @documentation("Id for the pet")
        $petId
    }
    output: Pet
}
