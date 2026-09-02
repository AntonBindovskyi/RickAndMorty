//
//  AppFeature.swift
//  Modules
//
//  Created by Anton Bindovskyi on 02.09.2026.
//

import CharacterDetail
import CharactersList
import ComposableArchitecture
import Models

@Reducer
public struct AppFeature: Sendable {

    @Reducer
    public enum Path {
        case detail(CharacterDetail)
    }

    @ObservableState
    public struct State: Equatable {
        public var list = CharactersList.State()
        public var path = StackState<Path.State>()

        public init() {}
    }

    public enum Action {
        case list(CharactersList.Action)
        case path(StackActionOf<Path>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.list, action: \.list) {
            CharactersList()
        }

        Reduce { state, action in
            switch action {

            case let .list(.delegate(.openDetail(character))):
                state.path.append(.detail(CharacterDetail.State(character: character)))
                return .none

            case .list:
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension AppFeature.Path.State: Equatable {}
