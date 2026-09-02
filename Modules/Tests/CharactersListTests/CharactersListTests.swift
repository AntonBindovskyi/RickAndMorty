//
//  CharactersListTests.swift
//  Modules
//
//  Created by Anton Bindovskyi on 02.09.2026.
//

import NetworkClient
import ComposableArchitecture
import Models
import Testing

@testable import CharactersList

@MainActor
@Suite("CharactersListTests", .serialized)
struct CharactersListTests {

    @Test("loadsFirstPage")
    func loadsFirstPage() async {
        let store = TestStore(initialState: CharactersList.State()) {
            CharactersList()
        } withDependencies: {
            $0.networkClient.characters = { _ in
                CharactersPage.stub(startID: 1, count: 3)
            }
        }

        await store.send(.onAppear) {
            $0.viewState = .loading
        }

        await store.receive(\.pageResponse) {
            $0.viewState = .loaded
            $0.currentPage = 1
            $0.hasNextPage = true
            $0.characters = IdentifiedArray(
                uniqueElements: (1...3).map(Character.stub(id:))
            )
        }
    }

    @Test("showsErrorWhenEmpty")
    func showsErrorWhenEmpty() async {
        let store = TestStore(initialState: CharactersList.State()) {
            CharactersList()
        } withDependencies: {
            $0.networkClient.characters = { _ in
                throw NetworkError.server(statusCode: 500)
            }
        }

        await store.send(.onAppear) {
            $0.viewState = .loading
        }

        await store.receive(\.pageResponse) {
            $0.viewState = .error(.server(statusCode: 500))
        }

        #expect(store.state.fullScreenError == .server(statusCode: 500))
    }

    @Test("retryRecovers")
    func retryRecovers() async {
        let shouldFail = LockIsolated(true)

        let store = TestStore(initialState: CharactersList.State()) {
            CharactersList()
        } withDependencies: {
            $0.networkClient.characters = { _ in
                if shouldFail.value {
                    throw NetworkError.connection(.notConnectedToInternet)
                }
                return CharactersPage.stub(startID: 1, count: 2)
            }
        }

        await store.send(.onAppear) { $0.viewState = .loading }
        await store.receive(\.pageResponse) {
            $0.viewState = .error(.connection(.notConnectedToInternet))
        }

        shouldFail.setValue(false)

        await store.send(.retryTapped) { $0.viewState = .loading }
        await store.receive(\.pageResponse) {
            $0.viewState = .loaded
            $0.currentPage = 1
            $0.characters = IdentifiedArray(
                uniqueElements: (1...2).map(Character.stub(id:))
            )
        }
    }

    @Test("errorKeepsExistingData")
    func errorKeepsExistingData() async {
        var initial = CharactersList.State()
        initial.characters = IdentifiedArray(uniqueElements: [Character.rick])
        initial.viewState = .loaded
        initial.currentPage = 1

        let store = TestStore(initialState: initial) {
            CharactersList()
        } withDependencies: {
            $0.networkClient.characters = { _ in
                throw NetworkError.connection(.notConnectedToInternet)
            }
        }

        await store.send(.reachedEnd) { $0.isLoadingMore = true }

        await store.receive(\.pageResponse) {
            $0.isLoadingMore = false
            $0.viewState = .loaded
        }

        #expect(store.state.characters.count == 1)
        #expect(store.state.fullScreenError == nil)
    }

    @Test("cancellationIsIgnored")
    func cancellationIsIgnored() async {
        var initial = CharactersList.State()
        initial.characters = IdentifiedArray(uniqueElements: [Character.rick])
        initial.viewState = .loaded

        let store = TestStore(initialState: initial) {
            CharactersList()
        } withDependencies: {
            $0.networkClient.characters = { _ in throw NetworkError.cancelled }
        }

        await store.send(.reachedEnd) { $0.isLoadingMore = true }
        await store.receive(\.pageResponse) {
            $0.isLoadingMore = false
        }
    }

    @Test("tapEmitsDelegate")
    func tapEmitsDelegate() async {
        let store = TestStore(initialState: CharactersList.State()) {
            CharactersList()
        }
        
        await store.send(.characterTapped(.rick))
        await store.receive(.delegate(.openDetail(.rick)))
    }
    
    @Test("onAppearDoesNotReload")
    func onAppearDoesNotReload() async {
        var initial = CharactersList.State()
        initial.characters = IdentifiedArray(uniqueElements: [Character.rick])
        initial.viewState = .loaded

        let store = TestStore(initialState: initial) {
            CharactersList()
        }

        await store.send(.onAppear)
    }

    @Test("stopsAtLastPage")
    func stopsAtLastPage() async {
        var initial = CharactersList.State()
        initial.characters = IdentifiedArray(uniqueElements: [Character.rick])
        initial.viewState = .loaded
        initial.currentPage = 1

        let store = TestStore(initialState: initial) {
            CharactersList()
        } withDependencies: {
            $0.networkClient.characters = { _ in
                CharactersPage.stub(startID: 21, count: 2, hasNextPage: false)
            }
        }

        await store.send(.reachedEnd) { $0.isLoadingMore = true }

        await store.receive(\.pageResponse) {
            $0.isLoadingMore = false
            $0.currentPage = 2
            $0.hasNextPage = false
            $0.characters.append(contentsOf: (21...22).map(Character.stub(id:)))
        }

        await store.send(.reachedEnd)
    }
}
