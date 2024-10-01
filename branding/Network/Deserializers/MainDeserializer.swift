import Foundation
import PromiseKit
import SwiftyJSON

// MARK: - Protocols

protocol ItemDeserializerProtocol: class {
    associatedtype ResponseItemType: JSONSerializable
    func deserialize(serialized: JSON) -> ResponseItemType
}

protocol CollectionDeserializerProtocol: class {
    associatedtype ResponseItemType: JSONSerializable
    func deserialize(serialized: JSON) -> [ResponseItemType]
}

protocol MixedCollectionDeserializerProtocol: class {
    associatedtype ResponseItemType: JSONSerializable
    func deserialize(serialized: JSON) -> ([ResponseItemType], Meta?)
}

// MARK: - Implementations

final class MetaDeserializer {
    func deserialize(serialized: JSON) -> Meta {
        return Meta(
            total: serialized["total"].intValue,
            page: serialized["page"].intValue
        )
    }
}

final class ItemDeserializer<T: JSONSerializable>: ItemDeserializerProtocol {
    func deserialize(serialized: JSON) -> T {
        return T(json: serialized)
    }
}

final class CollectionDeserializer<T: JSONSerializable>:
    CollectionDeserializerProtocol {
    private let oneItemDeserializer = ItemDeserializer<T>()

    func deserialize(serialized: JSON) -> [T] {
        let items: [T] = serialized.arrayValue.map { json in
            oneItemDeserializer.deserialize(serialized: json)
        }
        return items
    }
}

// MARK: - Mapper

final class FieldsMapper<T: JSONSerializable> {
    static func mapOne(id: String, target: inout T, objects: [T]) {
        for match in objects where match.id == id {
            target = match
            break
        }
    }

    static func mapCollection(ids: [String], target: inout [T], objects: [T]) {
        for match in objects {
            if ids.contains(where: { $0 == match.id }) {
                target.append(match)
            }
        }
    }
}
