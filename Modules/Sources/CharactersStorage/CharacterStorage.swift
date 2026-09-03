//
//  CharacterStorage.swift
//  Modules
//
//  Created by Anton Bindovskyi on 03.09.2026.
//

import Dependencies
import DependenciesMacros
import Foundation
import Models

@DependencyClient
public struct CharactersStorage: Sendable {
    public var load: @Sendable () async throws -> [Character]
    public var save: @Sendable (_ characters: [Character]) async throws -> Void
    public var clear: @Sendable () async throws -> Void
}

extension CharactersStorage: TestDependencyKey {
    public static let testValue = Self()
    public static let noop = Self(
        load: { [] },
        save: { _ in },
        clear: { }
    )
}

extension DependencyValues {
    public var charactersStorage: CharactersStorage {
        get { self[CharactersStorage.self] }
        set { self[CharactersStorage.self] = newValue }
    }
}
