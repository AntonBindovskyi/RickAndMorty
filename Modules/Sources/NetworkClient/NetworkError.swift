//
//  NetworkError.swift
//  Modules
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case connection(URLError.Code)
    case server(statusCode: Int)
    case decoding(description: String)
    case cancelled
    case unknown(description: String)
}

extension NetworkError {
    public var isRetriable: Bool {
        switch self {
        case .connection:
            true
        case let .server(statusCode):
            statusCode >= 500 || statusCode == 429
        case .decoding:
            false
        case .cancelled:
            false
        case .unknown:
            true
        }
    }

    public var isCancellation: Bool {
        self == .cancelled
    }
}

extension NetworkError {
    public init(underlying error: any Error) {
        switch error {
        case let apiError as NetworkError:
            self = apiError

        case is CancellationError:
            self = .cancelled

        case let urlError as URLError where urlError.code == .cancelled:
            self = .cancelled

        case let urlError as URLError:
            self = .connection(urlError.code)

        case let decodingError as DecodingError:
            self = .decoding(description: String(describing: decodingError))

        default:
            self = .unknown(description: String(describing: error))
        }
    }
}
