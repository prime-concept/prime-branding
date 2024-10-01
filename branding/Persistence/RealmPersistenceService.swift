import Foundation
import PromiseKit
import RealmSwift

final class RealmPersistenceService {
    private let currentSchemaVersion: UInt64 = 0

    private lazy var config = Realm.Configuration(
        schemaVersion: currentSchemaVersion,
        migrationBlock: { _, _ in
            // potentially lengthy data migration
        },
        deleteRealmIfMigrationNeeded: true
    )

    static let shared = RealmPersistenceService()

    private init() {}

    func write<T: RealmObjectConvertable>(objects: [T]) {
        do {
            let realm = try Realm(configuration: config)
            try realm.write {
                for object in objects {
                    realm.add(object.realmObject, update: .all)
                }
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func write<T: RealmObjectConvertable>(object: T) {
        write(objects: [object])
    }

    func read<T: RealmObjectConvertable>(type: T.Type, predicate: NSPredicate) -> [T] {
        do {
            let realm = try Realm(configuration: config)
            let results = realm
                .objects(T.RealmObjectType.self)
                .filter(predicate)
                .map { T(realmObject: $0) }

            return Array(results)
        } catch {
            assertionFailure(error.localizedDescription)
            return []
        }
    }

    func delete<T: RealmObjectConvertable>(type: T.Type, predicate: NSPredicate) {
        do {
            let realm = try Realm(configuration: config)
            let objects = realm
                .objects(T.RealmObjectType.self)
                .filter(predicate)

            guard let strongObject = objects.first else {
                return
            }

            try realm.write {
                realm.delete(strongObject)
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

	func deleteAll() {
		do {
			let realm = try Realm(configuration: config)
			try realm.write {
				realm.deleteAll()
			}
		} catch {
			assertionFailure(error.localizedDescription)
		}
	}
}
