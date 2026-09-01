//
//  CharacterDTO.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Foundation
import Models

struct CharacterDTO: Decodable, Equatable {

    struct Place: Decodable, Equatable {
        let name: String
    }

    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let image: String
    let origin: Place
    let location: Place
    let episode: [String]
}

extension CharacterDTO {
    var asDomain: Character {
        get throws {
            guard let imageURL = URL(string: image) else {
                throw NetworkError.decoding(
                    description: "Invalid image URL for character id \(id): \(image)"
                )
            }

            return Character(
                id: id,
                name: name,
                status: Character.Status(value: status),
                species: species,
                gender: Character.Gender(value: gender),
                imageURL: imageURL,
                originName: origin.name,
                locationName: location.name,
                episodeCount: episode.count
            )
        }
    }
}
