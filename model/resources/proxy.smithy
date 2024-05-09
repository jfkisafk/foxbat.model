$version: "2"

namespace dev.stelo.foxbat

@range(min: 1, max: 100)
integer PageSize

resource DynamoProxyItem {
    identifiers: {
        itemId: NonEmptyString
    }

    properties: {
        count: Long
        createdAt: Long
        lastModifiedAt: Long
        expiresAt: Long
    }

    create: CreateDynamoProxyItem
    update: UpdateDynamoProxyItem
    read: GetDynamoProxyItem
    delete: DeleteDynamoProxyItem
    list: ListDynamoProxyItems
}

@mixin
structure DynamoProxyItemElements for DynamoProxyItem {
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

structure DynamoProxyListItem for DynamoProxyItem with [DynamoProxyItemElements] {}

list DynamoProxyItemList {
    member: DynamoProxyListItem
}

enum ContentType {
    APPLICATION_JSON = "application/json"
}

resource S3ProxyItem {
    identifiers: {
        key: NonEmptyString
    }

    properties: {
        content: NonEmptyString
        contentType: ContentType
        version: NonEmptyString
    }

    put: PutS3ProxyItem
    read: GetS3ProxyItem
}

@mixin
structure S3ProxyItemKey for S3ProxyItem {
    @required
    @httpLabel
    @documentation("Key for the S3 object")
    $key
}

@mixin
structure S3ProxyItemContent for S3ProxyItem {
    @recommended
    @documentation("Content/data for the object")
    $content
}
