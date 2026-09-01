//
//  Mock.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Foundation
import Testing

enum JSONFixture: String {
    case charactersPage1 = "characters_page_1"
    case charactersPageLast = "characters_page_last"
    case characterWithImageError = "character_with_image_error"
    case characterWithUnknownCase = "character_with_unknown_case"
    case charactersListTypeError = "characters_list_type_error"
    case charactersListError = "characters_list_error"

    func data(sourceLocation: SourceLocation = #_sourceLocation) throws -> Data {
        let url = try #require(
            Bundle.module.url(forResource: rawValue, withExtension: "json"),
            "Mock \(rawValue).json was not found in Bundle.module",
            sourceLocation: sourceLocation
        )
        return try Data(contentsOf: url)
    }

    func decoded<T: Decodable>(
        as type: T.Type = T.self,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws -> T {
        try JSONDecoder().decode(type, from: data(sourceLocation: sourceLocation))
    }
}
