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
