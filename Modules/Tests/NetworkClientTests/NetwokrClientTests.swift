//
//  NetwokrClientTests.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Dependencies
import Foundation
import Models
import Testing

@testable import NetworkClient

@Suite("NetworkClientTests", .serialized)
struct NetworkClientTests {

    private func withStub<T>(
        _ handler: @escaping @Sendable (URLRequest) throws -> URLProtocolStub.Response,
        operation: (NetworkClient) async throws -> T
    ) async throws -> T {
        try await URLProtocolStub.withValue(handler) {
            try await operation(NetworkClient.live(session: .stubbed))
        }
    }

    @Test("buildsPagedURL")
    func buildsPagedURL() throws {
        let url = try Endpoint.characters(page: 1).url
        #expect(url.absoluteString == "https://rickandmortyapi.com/api/character?page=1")
    }

    @Test("requestsExpectedURL")
    func requestsExpectedURL() async throws {
        let captured = LockIsolated<URL?>(nil)

        _ = try await withStub { request in
            captured.setValue(request.url)
            return .ok(try JSONFixture.charactersPage1.data())
        } operation: { client in
            try await client.characters(page: 3)
        }

        #expect(captured.value?.absoluteString == "https://rickandmortyapi.com/api/character?page=3")
    }

    @Test("decodesSuccessfulResponse")
    func decodesSuccessfulResponse() async throws {
        let page = try await withStub { _ in
            .ok(try JSONFixture.charactersPage1.data())
        } operation: { client in
            try await client.characters(page: 1)
        }

        #expect(page.characters.count == 4)
        #expect(page.pageCount == 42)
        #expect(page.hasNextPage == true)
        #expect(page.characters.map(\.id) == [1, 250, 580, 821])
    }

    @Test("decodesLastPage")
    func decodesLastPage() async throws {
        let page = try await withStub { _ in
            .ok(try JSONFixture.charactersPageLast.data())
        } operation: { client in
            try await client.characters(page: 42)
        }

        #expect(page.hasNextPage == false)
        #expect(page.characters.count == 6)
    }

    @Test("mapServerError")
    func mapsServerError() async throws {
        await #expect(throws: NetworkError.server(statusCode: 500)) {
            try await withStub { _ in
                .status(500, data: Data("Internal Server Error".utf8))
            } operation: { client in
                try await client.characters(page: 1)
            }
        }

        #expect(NetworkError.server(statusCode: 500).isRetriable == true)
    }

    @Test("clientErrorIsNotRetriable")
    func clientErrorIsNotRetriable() async throws {
        await #expect(throws: NetworkError.server(statusCode: 404)) {
            try await withStub { _ in
                .status(404)
            } operation: { client in
                try await client.characters(page: 999)
            }
        }

        #expect(NetworkError.server(statusCode: 404).isRetriable == false)
    }

    @Test("statusIsCheckedBeforeDecoding")
    func statusIsCheckedBeforeDecoding() async throws {
        await #expect(throws: NetworkError.server(statusCode: 503)) {
            try await withStub { _ in
                .status(503, data: try JSONFixture.charactersPage1.data())
            } operation: { client in
                try await client.characters(page: 1)
            }
        }
    }

    @Test("mapCorruptedJSON")
    func mapCorruptedJSON() async throws {
        let error = await #expect(throws: NetworkError.self) {
            try await withStub { _ in
                .ok(Data("{ Not a JSON { |".utf8))
            } operation: { client in
                try await client.characters(page: 1)
            }
        }

        guard case .decoding = try #require(error) else {
            Issue.record("Expected '.decoding'; got: \(String(describing: error))")
            return
        }
        #expect(try #require(error).isRetriable == false)
    }

    @Test("mapSchemaMismatch")
    func mapSchemaMismatch() async throws {
        let error = await #expect(throws: NetworkError.self) {
            try await withStub { _ in
                .ok(try JSONFixture.charactersListTypeError.data())
            } operation: { client in
                try await client.characters(page: 1)
            }
        }

        guard case .decoding = try #require(error) else {
            Issue.record("Expected '.decoding'; got: \(String(describing: error))")
            return
        }
    }

    @Test("mapsConnectionFailure")
    func mapConnectionFailure() async throws {
        let error = await #expect(throws: NetworkError.self) {
            try await withStub { _ in
                throw URLError(.notConnectedToInternet)
            } operation: { client in
                try await client.characters(page: 1)
            }
        }

        #expect(try #require(error) == .connection(.notConnectedToInternet))
        #expect(try #require(error).isRetriable == true)
    }

    @Test("mapCancellation")
    func mapCancellation() async throws {
        let error = await #expect(throws: NetworkError.self) {
            try await withStub { _ in
                throw URLError(.cancelled)
            } operation: { client in
                try await client.characters(page: 1)
            }
        }

        #expect(try #require(error) == .cancelled)
        #expect(try #require(error).isRetriable == false)
        #expect(try #require(error).isCancellation == true)
    }

    @Test("resolvesThroughDependencyValues")
    func resolvesThroughDependencyValues() async throws {
        let page = try await withDependencies {
            $0.networkClient.characters = { requestedPage in
                CharactersPage.stub(startID: 1, count: 2, hasNextPage: requestedPage < 42)
            }
        } operation: {
            @Dependency(\.networkClient) var networkClient
            return try await networkClient.characters(page: 1)
        }

        #expect(page.characters.count == 2)
    }
}
