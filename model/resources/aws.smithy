$version: "2"

namespace dev.stelo.foxbat

@range(min: 1, max: 100)
integer PageSize

resource DynamoItem {
    identifiers: {
        itemId: NonEmptyString
    }

    properties: {
        count: Long
        createdAt: Long
        lastModifiedAt: Long
        expiresAt: Long
    }

    create: CreateDynamoItem
    update: UpdateDynamoItem
    read: GetDynamoItem
    delete: DeleteDynamoItem
    list: ListDynamoItems
}

@mixin
structure DynamoItemAttributes for DynamoItem {
    @required
    @documentation("Primary key for the item")
    $itemId

    @required
    @documentation("Frequency count for the item")
    $count

    @required
    @documentation("Ttl epoch for the item")
    $expiresAt

    @required
    @documentation("Creation epoch for the item")
    $createdAt

    @required
    @documentation("Last update epoch for the item")
    $lastModifiedAt
}

structure DynamoListElement for DynamoItem with [DynamoItemAttributes] {}

list DynamoItemList {
    member: DynamoListElement
}

enum ContentType {
    APPLICATION_JSON = "application/json"
}

resource S3Item {
    identifiers: {
        key: NonEmptyString
    }

    properties: {
        content: NonEmptyString
        contentType: ContentType
        version: NonEmptyString
    }

    put: PutS3Item
    read: GetS3Item
}

@mixin
structure S3ItemKey for S3Item {
    @required
    @httpLabel
    @documentation("Key for the S3 object")
    $key
}

@mixin
structure S3ItemContent for S3Item {
    @recommended
    @documentation("Content/data for the object")
    $content
}
