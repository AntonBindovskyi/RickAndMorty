//
//  NetworkClient.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Dependencies
import DependenciesMacros
import Foundation
import Models


@DependencyClient
public struct NetworkClient: Sendable {
    public var characters: @Sendable (_ page: Int) async throws -> CharactersPage
}

// MARK: - Реєстрація

extension NetworkClient: DependencyKey {
    public static let liveValue = NetworkClient.live()

    static func live(session: URLSession = .release) -> Self {
        let decoder = JSONDecoder()
        
        return Self(
            characters: { page in
                let url = try Endpoint.characters(page: page).url
                let response: CharactersResponseDTO = try await session.decode(
                    url,
                    as: CharactersResponseDTO.self,
                    decoder: decoder
                )
                return try response.asDomain
            }
        )
    }
}

enum Endpoint {
    static let baseURL = URL(string: "https://rickandmortyapi.com/api")!
    
    case characters(page: Int)

    var url: URL {
        get throws {
            switch self {
            case let .characters(page):
                var components = URLComponents(
                    url: Self.baseURL.appendingPathComponent("character"),
                    resolvingAgainstBaseURL: false
                )
                components?.queryItems = [
                    URLQueryItem(name: "page", value: String(page))
                ]
                guard let url = components?.url else {
                    throw NetworkError.unknown(description: "Failed URL creation for characters page \(page)")
                }

                return url
            }
        }
    }
}

extension URLSession {

    static let release: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = false
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: configuration)
    }()

    func decode<T: Decodable>(
        _ url: URL,
        as type: T.Type,
        decoder: JSONDecoder
    ) async throws -> T {
        do {
            let (data, response) = try await data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(description: "Non-HTTP response for \(url)")
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.server(statusCode: httpResponse.statusCode)
            }

            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError(underlying: error)
        }
    }
}

extension DependencyValues {
    public var networkClient: NetworkClient {
        get { self[NetworkClient.self] }
        set { self[NetworkClient.self] = newValue }
    }
}
