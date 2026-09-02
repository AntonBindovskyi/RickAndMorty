//
//  AppView.swift
//  Modules
//
//  Created by Anton Bindovskyi on 02.09.2026.
//

import CharacterDetail
import CharactersList
import ComposableArchitecture
import SwiftUI

public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            CharactersListView(
                store: store.scope(state: \.list, action: \.list)
            )
        } destination: { store in
            switch store.case {
            case let .detail(detailStore):
                CharacterDetailView(store: detailStore)
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.networkClient = .previewValue
        }
    )
}
