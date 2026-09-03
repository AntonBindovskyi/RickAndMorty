//
//  CharacterObject.swift
//  Modules
//
//  Created by Anton Bindovskyi on 03.09.2026.
//

import Foundation
import Models
import RealmSwift

nonisolated final class CharacterObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var species: String
    @Persisted var status: String
    @Persisted var gender: String
    @Persisted var imageURLString: String
    @Persisted var originName: String
    @Persisted var locationName: String
    @Persisted var episodeCount: Int
    @Persisted var updatedAt: Date

    convenience init(_ character: Character, updatedAt: Date) {
        self.init()
        self.id = character.id
        self.name = character.name
        self.species = character.species
        self.status = character.status.rawValue
        self.gender = character.gender.rawValue
        self.imageURLString = character.imageURL.absoluteString
        self.originName = character.originName
        self.locationName = character.locationName
        self.episodeCount = character.episodeCount
        self.updatedAt = updatedAt
    }
}

extension CharacterObject {
    var asDomain: Character? {
        guard let imageURL = URL(string: imageURLString) else {
            return nil
        }

        return Character(
            id: id,
            name: name,
            status: Character.Status(value: status),
            species: species,
            gender: Character.Gender(value: gender),
            imageURL: imageURL,
            originName: originName,
            locationName: locationName,
            episodeCount: episodeCount
        )
    }
}
