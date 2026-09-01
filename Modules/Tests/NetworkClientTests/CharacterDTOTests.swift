//
//  CharacterDTOTests.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Foundation
import Models
import Testing

@testable import NetworkClient

@Suite("CharacterDTO mapping")
struct CharacterDTOTests {

    @Test("decodesRealPage")
    func decodesRealPage() throws {
        let page = try JSONFixture.charactersPage1
            .decoded(as: CharactersResponseDTO.self)
            .asDomain

        #expect(page.pageCount == 42)
        #expect(page.hasNextPage == true)
        #expect(page.characters.count == 4)

        let rick = try #require(page.characters.first)
        #expect(rick.id == 1)
        #expect(rick.name == "Rick Sanchez")
        #expect(rick.status == .alive)
        #expect(rick.gender == .male)
        #expect(rick.species == "Human")
        #expect(rick.originName == "Earth (C-137)")
        #expect(rick.locationName == "Citadel of Ricks")
        #expect(rick.episodeCount == 1)
    }

    @Test("normalizesStatusCase")
    func normalizesStatusCase() throws {
        let page = try JSONFixture.charactersPage1
            .decoded(as: CharactersResponseDTO.self)
            .asDomain

        #expect(page.characters.map(\.status) == [.alive, .dead, .alive, .unknown])
        #expect(page.characters.map(\.gender) == [.male, .female, .male, .genderless])
    }

    @Test("preservesOrder")
    func preservesOrder() throws {
        let page = try JSONFixture.charactersPage1
            .decoded(as: CharactersResponseDTO.self)
            .asDomain

        #expect(page.characters.map(\.id) == [1, 250, 580, 821])
    }

    @Test("unknownEnumValuesDoNotThrow")
    func unknownEnumValuesDoNotThrow() throws {
        let character = try JSONFixture.characterWithUnknownCase
            .decoded(as: CharacterDTO.self)
            .asDomain

        #expect(character.status == .unknown)
        #expect(character.gender == .unknown)
        #expect(character.episodeCount == 1)
    }

    @Test("invalidImageURLThrows")
    func invalidImageURLThrows() throws {
        let dto = try JSONFixture.characterWithImageError
            .decoded(as: CharacterDTO.self)

        #expect(throws: NetworkError.self) {
            _ = try dto.asDomain
        }
    }

    @Test("lastPageHasNoNext")
    func lastPageHasNoNext() throws {
        let page = try JSONFixture.charactersPageLast
            .decoded(as: CharactersResponseDTO.self)
            .asDomain

        #expect(page.hasNextPage == false)
        #expect(!page.characters.isEmpty)
    }

    @Test("malformedSchemaThrows")
    func malformedSchemaThrows() throws {
        #expect(throws: DecodingError.self) {
            _ = try JSONFixture.charactersListTypeError
                .decoded(as: CharactersResponseDTO.self)
        }
    }
}
