//
//  CharacterStorage+RealmStore.swift
//  Modules
//
//  Created by Anton Bindovskyi on 03.09.2026.
//

import CharactersStorage
import Foundation
import Models
import RealmSwift

extension CharactersStorage {
    public static var onDisk: CharactersStorage {
        make(configuration: .configurationOnDisk)
    }

    public static func inMemory(id: String = UUID().uuidString) -> CharactersStorage {
        make(configuration: .configurationInMemory(id: id))
    }

    static func make(configuration: Realm.Configuration) -> CharactersStorage {
        let store = RealmStore(configuration: configuration)

        return CharactersStorage(
            load: { try await store.load() },
            save: { characters in try await store.save(characters) },
            clear: { try await store.clear() }
        )
    }
}
