$version: "2"

namespace dev.stelo.foxbat

use aws.apigateway#integration

@integration(
    type: "http"
    httpMethod: "GET"
    uri: "http://petstore-demo-endpoint.execute-api.com/petstore/pets"
    requestParameters: {
        "integration.request.querystring.type": "method.request.querystring.type",
        "integration.request.querystring.page": "method.request.querystring.page"
    }
    responses: {
        default: {
            statusCode: "200"
            responseTemplates: {
                "application/json": """
                {
                  "pets": $input.json('$')
                }
                """
            }
        }
    }
)
@tags(["http", "custom", "petstore"])
@readonly
@examples([
    {
        title: "example w/o queries"
        output: {
            pets: [
                {
                    id: 1
                    type: "dog"
                    price: 249.99
                }
                {
                    id: 2
                    type: "cat"
                    price: 124.99
                }
                {
                    id: 3
                    type: "fish"
                    price: 0.99
                }
            ]
        }
    },
    {
        title: "example with queries"
        input: { type: "bird" }
        output: {
            pets: [
                {
                    id: 1
                    type: "bird"
                    "price": 999.99
                }
                {
                    id: 2
                    type: "bird"
                    price: 249.99
                }
                {
                    id: 3
                    type: "bird"
                    price: 49.97
                }
            ]

        }
    }
])
@documentation("List pets from execute-api petstore")
@http(code: 200, method: "GET", uri: "/pets")
operation ListPets with [BaseOperationErrors] {
    input := for PetStore {
        @recommended
        @documentation("Type for the pet")
        @httpQuery("type")
        $type
    }
    output := {
        @required
        @documentation("Pets from the petstore")
        pets: PetList
    }
}
