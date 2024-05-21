$version: "2"

namespace dev.stelo.foxbat

resource PetStore {
    identifiers: { petId: String }

    properties: {
        id: Integer
        type: NonEmptyString
        price: Double
        errors: PetErrorList
    }

    read: GetPet
    list: ListPets
}

structure PetError {
    @required
    @documentation("Error key")
    key: NonEmptyString

    @required
    @documentation("Error message")
    message: NonEmptyString
}

list PetErrorList {
    member: PetError
}

structure Pet for PetStore {
    @documentation("Id for the pet")
    $id

    @documentation("Type for the pet")
    $type

    @documentation("Price for the pet")
    $price

    @documentation("Errors for the call")
    $errors
}

list PetList {
    member: Pet
}
