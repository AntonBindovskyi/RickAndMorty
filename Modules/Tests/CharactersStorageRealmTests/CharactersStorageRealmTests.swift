//
//  CharacterStorageRealmTests.swift
//  Modules
//
//  Created by Anton Bindovskyi on 03.09.2026.
//

import Foundation
import Models
import RealmSwift
import Testing

@testable import CharactersStorageRealm

@Suite("CharacterObjectTests")
struct CharacterObjectTests {

    @Test("roundTripPreservesFields")
    func roundTripPreservesFields() throws {
        let original = Character.rick
        let object = CharacterObject(original)

        let restored = try #require(object.asDomain)

        #expect(restored == original)
    }

    @Test("preservesEnums")
    func preservesEnums() throws {
        for character in [Character.rick, .morty, .smith] {
            let object = CharacterObject(character)
            let restored = try #require(object.asDomain)

            #expect(restored.status == character.status)
            #expect(restored.gender == character.gender)
        }
    }

    @Test("unknownRawValueDegrades")
    func unknownRawValueDegrades() throws {
        let object = CharacterObject(.rick)
        object.status = "superposed"
        object.gender = "yes"

        let restored = try #require(object.asDomain)

        #expect(restored.status == .unknown)
        #expect(restored.gender == .unknown)
    }

    @Test("invalidRecordReturnsNil")
    func invalidRecordReturnsNil() {
        let object = CharacterObject(.rick)
        object.imageURLString = ""

        #expect(object.asDomain == nil)
    }

    @Test("persistsToRealm")
    func persistsToRealm() throws {
        let realm = try Realm(configuration: .configurationInMemory())

        try realm.write {
            realm.add(CharacterObject(.rick))
        }

        let stored = try #require(realm.object(ofType: CharacterObject.self, forPrimaryKey: 1))
        #expect(stored.name == "Rick Sanchez")
        #expect(realm.objects(CharacterObject.self).count == 1)
    }
}
