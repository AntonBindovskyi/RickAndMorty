//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Anton Bindovskyi on 01.09.2026.
//

import AppFeature
import CharactersStorage
import CharactersStorageRealm
import ComposableArchitecture
import Nuke
import SwiftUI

@main
struct RickAndMortyApp: App {
    
    init() {
        prepareDependencies {
            $0.charactersStorage = .onDisk
        }
        
        ImagePipeline.shared = .charactersPipeline
    }
    
    @MainActor
    private static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
