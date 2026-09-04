//
//  RealmStore.swift
//  Modules
//
//  Created by Anton Bindovskyi on 03.09.2026.
//

import Foundation
import Models
import RealmSwift

actor RealmStore {
    private let configuration: Realm.Configuration
    private var cachedRealm: Realm?

    init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }

    private func realm() async throws -> Realm {
        if let cachedRealm { return cachedRealm }
        let realm = try await Realm(configuration: configuration, actor: self)
        cachedRealm = realm
        return realm
    }

    func load() async throws -> [Character] {
        let realm = try await realm()

        return realm.objects(CharacterObject.self)
            .sorted(by: [
                SortDescriptor(keyPath: "id")
            ])
            .compactMap(\.asDomain)
    }

    func save(_ characters: [Character]) async throws {
        let realm = try await realm()

        try await realm.asyncWrite {
            realm.add(
                characters.map { CharacterObject($0) },
                update: .modified
            )
        }
    }

    func clear() async throws {
        let realm = try await realm()
        try await realm.asyncWrite {
            realm.deleteAll()
        }
    }
}

extension Realm.Configuration {
    static var configurationOnDisk: Self {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.objectTypes = [CharacterObject.self]
        configuration.schemaVersion = 1
        configuration.deleteRealmIfMigrationNeeded = true
        return configuration
    }

    static func configurationInMemory(id: String = UUID().uuidString) -> Self {
        Realm.Configuration(
            inMemoryIdentifier: id,
            objectTypes: [CharacterObject.self]
        )
    }
}
