//
//  CharacrtersStorageRealm.swift
//  Modules
//
//  Created by Anton Bindovskyi on 03.09.2026.
//

import CharactersStorage
import Foundation
import Models
import Testing

@testable import CharactersStorageRealm

@Suite("CharactersStorage (Realm)")
struct CharactersStorageTests {

    @Test("loadsEmpty")
    func loadsEmpty() async throws {
        let storage = CharactersStorage.inMemory()
        let characters = try await storage.load()

        #expect(characters.isEmpty)
    }

    @Test("restoresOrderByID")
    func restoresOrderByID() async throws {
        let storage = CharactersStorage.inMemory()

        try await storage.save([.stub(id: 30), .stub(id: 10)])
        try await storage.save([.stub(id: 20), .stub(id: 5)])

        let loaded = try await storage.load()

        #expect(loaded.map(\.id) == [5, 10, 20, 30])
    }

    @Test("upsertsInsteadOfDuplicating")
    func upsertsInsteadOfDuplicating() async throws {
        let storage = CharactersStorage.inMemory()
        let page = [Character.rick, .morty]

        try await storage.save(page)
        try await storage.save(page)

        let loaded = try await storage.load()

        #expect(loaded.count == 2)
    }

    @Test("upsertUpdatesFields")
    func upsertUpdatesFields() async throws {
        let storage = CharactersStorage.inMemory()

        try await storage.save([.morty])

        let updated = Character(
            id: Character.morty.id,
            name: "Rick Sanchez (C-137)",
            status: .dead,
            species: Character.rick.species,
            gender: Character.rick.gender,
            imageURL: Character.rick.imageURL,
            originName: Character.rick.originName,
            locationName: "Nowhere",
            episodeCount: 99
        )
        try await storage.save([updated])

        let loaded = try await storage.load()

        #expect(loaded.count == 1)
        #expect(loaded.first == updated)
    }

    @Test("clearsEverything")
    func clearsEverything() async throws {
        let storage = CharactersStorage.inMemory()

        try await storage.save([.rick, .morty, .smith])
        #expect(try await storage.load().count == 3)

        try await storage.clear()
        #expect(try await storage.load().isEmpty)
    }

    @Test("instancesAreIsolated")
    func instancesAreIsolated() async throws {
        let first = CharactersStorage.inMemory()
        let second = CharactersStorage.inMemory()

        try await first.save([.rick, .morty])

        #expect(try await first.load().count == 2)
        #expect(try await second.load().isEmpty)
    }

    @Test("accumulatesPages")
    func accumulatesPages() async throws {
        let storage = CharactersStorage.inMemory()

        try await storage.save((1...10).map(Character.stub(id:)))
        try await storage.save((5...15).map(Character.stub(id:)))

        let loaded = try await storage.load()

        #expect(loaded.count == 15)
        #expect(loaded.map(\.id) == Array(1...15))
    }

    @Test("handlesConcurrentWrites")
    func handlesConcurrentWrites() async throws {
        let storage = CharactersStorage.inMemory()

        await withTaskGroup(of: Void.self) { group in
            for page in 0..<5 {
                group.addTask {
                    let ids = (page * 10 + 1)...(page * 10 + 10)
                    try? await storage.save(ids.map(Character.stub(id:)))
                }
            }
        }

        let loaded = try await storage.load()

        #expect(loaded.count == 50)
        #expect(loaded.map(\.id) == Array(1...50))
    }

    @Test("handlesConcurrentReadsAndWrites")
    func handlesConcurrentReadsAndWrites() async throws {
        let storage = CharactersStorage.inMemory()
        try await storage.save((1...10).map(Character.stub(id:)))

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    _ = try? await storage.load()
                }
                group.addTask {
                    try? await storage.save((11...20).map(Character.stub(id:)))
                }
            }
        }

        #expect(try await storage.load().count == 20)
    }
}
