//
//  CharactersResponseDTO.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Foundation
import Models

struct CharactersResponseDTO: Decodable, Equatable {
    struct Info: Decodable, Equatable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }

    let info: Info
    let results: [CharacterDTO]
}

extension CharactersResponseDTO {
    var asDomain: CharactersPage {
        get throws {
            CharactersPage(
                characters: try results.map { try $0.asDomain },
                pageCount: info.pages,
                hasNextPage: info.next != nil
            )
        }
    }
}
