//
//  CharacterDetail.swift
//  Modules
//
//  Created by Anton Bindovskyi on 02.09.2026.
//

import NetworkClient
import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct CharacterDetail: Sendable {
    
    @ObservableState
    public struct State: Equatable {
        public var character: Character
        
        public init(character: Character) {
            self.character = character
        }
    }
    
    public enum Action: Equatable {
        
    }
    
    public init() {
        
    }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
