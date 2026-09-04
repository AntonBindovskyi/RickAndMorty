//
//  ChatactesListView.swift
//  Modules
//
//  Created by Anton Bindovskyi on 02.09.2026.
//

import ComposableArchitecture
import Models
import NetworkClient
import SwiftUI

public struct CharactersListView: View {
    let store: StoreOf<CharactersList>

    public init(store: StoreOf<CharactersList>) {
        self.store = store
    }

    private static let paginationThreshold = 3

    public var body: some View {
        content
            .navigationTitle("Characters")
            .onAppear { store.send(.onAppear) }
    }

    @ViewBuilder
    private var content: some View {
        if store.isInitialLoading {
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = store.fullScreenError {
            ListErrorStateView(error: error) {
                store.send(.retryTapped)
            }
        } else {
            VStack(spacing: 0) {
                list
            }
        }
    }

    private var list: some View {
        List {
            ForEach(store.characters) { character in
                Button {
                    store.send(.characterTapped(character))
                } label: {
                    CharacterRowView(character: character)
                }
                .buttonStyle(.plain)
                .onAppear {
                    guard shouldLoadMore(after: character) else { return }
                    store.send(.reachedEnd)
                }
            }
            if store.hasNextPage {
                paginationFooter
            }
        }
        .listStyle(.plain)
    }
    
    private var paginationFooter: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding(.vertical, 12)
        .listRowSeparator(.hidden)
        .id(store.characters.count)
        .onAppear { store.send(.reachedEnd) }
    }

    private var loadingFooter: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .listRowSeparator(.hidden)
    }

    private func shouldLoadMore(after character: Character) -> Bool {
        guard let index = store.characters.index(id: character.id) else {
            return false
        }
        return index >= store.characters.count - Self.paginationThreshold
    }
}

#Preview("Loaded") {
    NavigationStack {
        CharactersListView(
            store: Store(initialState: CharactersList.State()) {
                CharactersList()
            } withDependencies: {
                $0.networkClient = .previewValue
            }
        )
    }
}

#Preview("Error") {
    NavigationStack {
        CharactersListView(
            store: Store(initialState: CharactersList.State()) {
                CharactersList()
            } withDependencies: {
                $0.networkClient.characters = { _ in
                    throw NetworkError.connection(.notConnectedToInternet)
                }
            }
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        CharactersListView(
            store: Store(initialState: CharactersList.State()) {
                CharactersList()
            } withDependencies: {
                $0.networkClient.characters = { _ in
                    try await Task.sleep(for: .seconds(60))
                    fatalError()
                }
            }
        )
    }
}
