//
//  NetworkClient+Test.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Dependencies
import DependenciesMacros
import Foundation
import Models

extension NetworkClient: TestDependencyKey {
    public static let testValue = Self()

    public static let previewValue = Self(
        characters: { page in
            try await Task.sleep(for: .milliseconds(300))
            return CharactersPage.stub(
                startID: (page - 1) * 20 + 1,
                count: 20,
                pageCount: 42,
                hasNextPage: page < 42
            )
        }
    )
}
