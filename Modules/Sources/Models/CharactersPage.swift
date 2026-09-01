//
//  CharactersPage.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Foundation

public struct CharactersPage: Equatable, Hashable, Sendable, Codable {
    public let characters: [Character]
    public let pageCount: Int
    public let hasNextPage: Bool

    public init(
        characters: [Character],
        pageCount: Int,
        hasNextPage: Bool
    ) {
        self.characters = characters
        self.pageCount = pageCount
        self.hasNextPage = hasNextPage
    }
}
