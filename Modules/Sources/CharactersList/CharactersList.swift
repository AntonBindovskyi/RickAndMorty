//
//  CharactersList.swift
//  Modules
//
//  Created by Anton Bindovskyi on 02.09.2026.
//

import NetworkClient
import CharactersStorage
import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct CharactersList: Sendable {

    @ObservableState
    public struct State: Equatable {
        public enum ViewState: Equatable {
            case idle
            case loading
            case loaded
            case error(NetworkError)
        }

        public var characters: IdentifiedArrayOf<Character> = []
        public var viewState: ViewState = .idle
        public var currentPage: Int = 0
        public var hasNextPage: Bool = true
        public var isLoadingMore: Bool = false

        public init() {}

        var isInitialLoading: Bool {
            viewState == .loading && characters.isEmpty
        }

        var fullScreenError: NetworkError? {
            guard characters.isEmpty, case let .error(error) = viewState else {
                return nil
            }
            return error
        }
        var canLoadMore: Bool {
            hasNextPage && !isLoadingMore && currentPage > 0 && viewState == .loaded
        }
    }

    public enum Action: Equatable {
        case onAppear
        case retryTapped
        case characterTapped(Character)
        case reachedEnd
        case cacheLoaded([Character])
        case pageResponse(Result<CharactersPage, NetworkError>, page: Int)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable {
            case openDetail(Character)
        }
    }
    
    private enum CancelID: String {
        case pageRequest
        case cacheRead
    }

    @Dependency(\.networkClient) var networkClient
    @Dependency(\.charactersStorage) var storage

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                guard state.characters.isEmpty, state.viewState != .loading else {
                    return .none
                }
                state.viewState = .loading
                return .merge(
                    loadCache(),
                    fetch(page: 1)
                )

            case .retryTapped:
                return loadFirstPage(&state)

            case let .cacheLoaded(cached):
                guard state.characters.isEmpty, !cached.isEmpty else {
                    return .none
                }
                state.characters = IdentifiedArray(uniqueElements: cached)
                state.viewState = .loaded
                return .none

            case let .characterTapped(character):
                return .send(.delegate(.openDetail(character)))

            case .reachedEnd:
                print("reachedEnd: canLoadMore=\(state.canLoadMore) page=\(state.currentPage) loading=\(state.isLoadingMore) count=\(state.characters.count)")
                guard state.canLoadMore else {
                    return .none
                }
                state.isLoadingMore = true
                return fetch(page: state.currentPage + 1)

            case let .pageResponse(.success(page), pageNumber):
                state.isLoadingMore = false
                state.viewState = .loaded
                state.currentPage = pageNumber
                state.hasNextPage = page.hasNextPage
                state.characters.append(contentsOf: page.characters)

                return .run { [characters = page.characters] _ in
                    try? await storage.save(characters)
                }

            case let .pageResponse(.failure(error), _):
                state.isLoadingMore = false

                guard !error.isCancellation else {
                    return .none
                }

                if state.characters.isEmpty {
                    state.viewState = .error(error)
                } else {
                    state.viewState = .loaded
                }
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func loadFirstPage(_ state: inout State) -> Effect<Action> {
        state.viewState = .loading
        state.isLoadingMore = false
        state.hasNextPage = true
        return fetch(page: 1)
    }

    private func loadCache() -> Effect<Action> {
        .run { send in
            guard let cached = try? await storage.load(), !cached.isEmpty else {
                return
            }
            await send(.cacheLoaded(cached))
        }
        .cancellable(id: CancelID.cacheRead, cancelInFlight: true)
    }

    private func fetch(page: Int) -> Effect<Action> {
        return .run { send in
            await send(
                .pageResponse(
                    Result { try await networkClient.characters(page: page) }
                        .mapError { NetworkError(underlying: $0) },
                    page: page
                )
            )
        }
        .cancellable(id: CancelID.pageRequest, cancelInFlight: true)
    }
}
