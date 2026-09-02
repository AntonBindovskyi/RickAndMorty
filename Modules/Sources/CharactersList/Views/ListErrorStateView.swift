//
//  ListErrorStateView.swift
//  Modules
//
//  Created by Anton Bindovskyi on 02.09.2026.
//

import NetworkClient
import SwiftUI

struct ListErrorStateView: View {
    let error: NetworkError
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(message)
        } actions: {
            if error.isRetriable {
                Button("Retry", action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private var title: String {
        switch error {
        case .connection:
            "No connection"
        case .server:
            "Server error"
        case .decoding:
            "Decoding error"
        case .cancelled, .unknown:
            "Something went wrong"
        }
    }

    private var icon: String {
        switch error {
        case .connection:
            "wifi.slash"
        case .server:
            "exclamationmark.icloud"
        case .decoding:
            "doc.questionmark"
        case .cancelled, .unknown:
            "exclamationmark.triangle"
        }
    }

    private var message: String {
        switch error {
        case .connection:
            "Check your internet connection and try again."
        case let .server(statusCode):
            "The server responded with status \(statusCode)."
        case .decoding:
            "The server returned data in an unexpected format."
        case .cancelled:
            "The request was cancelled."
        case .unknown:
            "An unexpected error occurred."
        }
    }
}

#Preview("Connection") {
    ListErrorStateView(error: .connection(.notConnectedToInternet), retry: {})
}

#Preview("Not retriable") {
    ListErrorStateView(error: .server(statusCode: 404), retry: {})
}
