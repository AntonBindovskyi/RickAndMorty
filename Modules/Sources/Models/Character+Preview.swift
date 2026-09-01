//
//  Character+Preview.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

#if DEBUG
import Foundation

extension Character {

    public static let rick = Character(
        id: 1,
        name: "Rick Sanchez",
        status: .alive,
        species: "Human",
        gender: .male,
        imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!,
        originName: "Earth (C-137)",
        locationName: "Citadel of Ricks",
        episodeCount: 51
    )

    public static let morty = Character(
        id: 2,
        name: "Morty Smith",
        status: .alive,
        species: "Human",
        gender: .male,
        imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")!,
        originName: "unknown",
        locationName: "Citadel of Ricks",
        episodeCount: 51
    )

    public static let smith = Character(
        id: 4,
        name: "Summer Smith",
        status: .alive,
        species: "Human",
        gender: .female,
        imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/3.jpeg")!,
        originName: "Earth (Replacement Dimension)",
        locationName: "Earth (Replacement Dimension)",
        episodeCount: 1
    )

    public static func stub(id: Int) -> Character {
        Character(
            id: id,
            name: "Character \(id)",
            status: .alive,
            species: "Human",
            gender: .male,
            imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg")!,
            originName: "Earth",
            locationName: "Earth",
            episodeCount: 1
        )
    }
}

extension CharactersPage {

    public static let preview = CharactersPage(
        characters: [.rick, .morty, .smith],
        pageCount: 42,
        hasNextPage: true
    )

    public static func stub(
        startID: Int,
        count: Int,
        pageCount: Int = 42,
        hasNextPage: Bool = true
    ) -> CharactersPage {
        CharactersPage(
            characters: (startID..<(startID + count)).map(Character.stub(id:)),
            pageCount: pageCount,
            hasNextPage: hasNextPage
        )
    }
}
#endif
