//
//  Character.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Foundation

public struct Character: Identifiable, Equatable, Hashable, Sendable, Codable {

    public let id: Int
    public let name: String
    public let status: Status
    public let species: String
    public let gender: Gender
    public let imageURL: URL
    public let originName: String
    public let locationName: String
    public let episodeCount: Int

    public init(
        id: Int,
        name: String,
        status: Status,
        species: String,
        gender: Gender,
        imageURL: URL,
        originName: String,
        locationName: String,
        episodeCount: Int
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.gender = gender
        self.imageURL = imageURL
        self.originName = originName
        self.locationName = locationName
        self.episodeCount = episodeCount
    }
}

// MARK: - Status

extension Character {
    public enum Status: String, Equatable, Hashable, Sendable, Codable, CaseIterable {
        case alive
        case dead
        case unknown

        public init(value: String) {
            self = Status(rawValue: value.lowercased()) ?? .unknown
        }

        public var title: String {
            self.rawValue.capitalized
        }
    }
    
    public enum Gender: String, Equatable, Hashable, Sendable, Codable, CaseIterable {
        case male
        case female
        case unknown
        case genderless
        
        public init(value: String) {
            self = Gender(rawValue: value.lowercased()) ?? .unknown
        }
        
        public var title: String {
            self.rawValue.capitalized
        }
    }
}
