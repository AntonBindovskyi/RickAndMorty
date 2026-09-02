//
//  AppFeatureTests.swift
//  Modules
//
//  Created by Anton Bindovskyi on 02.09.2026.
//

import CharacterDetail
import CharactersList
import ComposableArchitecture
import Models
import Testing

@testable import AppFeature

@MainActor
@Suite("AppFeatureTests", .serialized)
struct AppFeatureTests {

    @Test("opensDetail")
    func opensDetail() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.list(.characterTapped(.rick)))

        await store.receive(\.list.delegate.openDetail) {
            $0.path[id: 0] = .detail(CharacterDetail.State(character: .rick))
        }
    }

    @Test("stacksMultipleScreens")
    func stacksMultipleScreens() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.list(.characterTapped(.rick)))
        await store.receive(\.list.delegate.openDetail) {
            $0.path[id: 0] = .detail(CharacterDetail.State(character: .rick))
        }

        await store.send(.list(.characterTapped(.morty)))
        await store.receive(\.list.delegate.openDetail) {
            $0.path[id: 1] = .detail(CharacterDetail.State(character: .morty))
        }

        #expect(store.state.path.count == 2)
    }

    @Test("popRemovesFromStack")
    func popRemovesFromStack() async {
        var initial = AppFeature.State()
        initial.path.append(.detail(CharacterDetail.State(character: .rick)))

        let store = TestStore(initialState: initial) {
            AppFeature()
        }

        await store.send(.path(.popFrom(id: store.state.path.ids[0]))) {
            $0.path.removeLast()
        }

        #expect(store.state.path.isEmpty)
    }

    @Test("passesCorrectCharacter")
    func passesCorrectCharacter() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.list(.characterTapped(.smith)))
        await store.receive(\.list.delegate.openDetail) {
            $0.path[id: 0] = .detail(CharacterDetail.State(character: .smith))
        }

        guard case let .detail(detail) = store.state.path.last else {
            Issue.record("Detail view was not set")
            return
        }
        #expect(detail.character.id == Character.smith.id)
    }
}
