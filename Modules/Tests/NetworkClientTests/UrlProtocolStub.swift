//
//  UrlProtocolStub.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Foundation

final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    private static let lock = NSLock()
    private nonisolated(unsafe) static var _handler: (@Sendable (URLRequest) throws -> Response)?

    static var handler: (@Sendable (URLRequest) throws -> Response)? {
        get { lock.withLock { _handler } }
        set { lock.withLock { _handler = newValue } }
    }

    static func withValue<T>(
        _ handler: @escaping @Sendable (URLRequest) throws -> Response,
        operation: () async throws -> T
    ) async rethrows -> T {
        let previous = Self.handler
        Self.handler = handler
        defer { Self.handler = previous }
        return try await operation()
    }

    struct Response {
        var statusCode: Int = 200
        var data: Data = Data()
        var headers: [String: String] = ["Content-Type": "application/json"]

        static func ok(_ data: Data) -> Self {
            Response(statusCode: 200, data: data)
        }

        static func status(_ code: Int, data: Data = Data()) -> Self {
            Response(statusCode: code, data: data)
        }
    }

    struct NotConfigured: Error {}

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: NotConfigured())
            return
        }

        do {
            let stub = try handler(request)

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: stub.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: stub.headers
            )!

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: stub.data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - for tests

extension URLSession {
    static var stubbed: URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: configuration)
    }
}
