//
//  CharacterDetailView.swift
//  Modules
//
//  Created by Anton Bindovskyi on 02.09.2026.
//

import ComposableArchitecture
import Models
import NukeUI
import SwiftUI

public struct CharacterDetailView: View {
    let store: StoreOf<CharacterDetail>
    
    public init(store: StoreOf<CharacterDetail>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack {
                image
                info
            }
            .padding()
        }
        .navigationTitle(store.character.name)
    }
    
    private var image: some View {
        LazyImage(url: store.character.imageURL) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
            } else if state.error != nil {
                Image(systemName: "person.slash")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fill)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var info: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(store.character.name)
                .font(.title2.weight(.semibold))
            
            HStack(spacing: 8) {
                Text("Status: \(store.character.status.title)")
                    .font(.subheadline.weight(.medium))
            }
            
            Divider()
            
            VStack(spacing: 8) {
                Row(title: "Species", value: store.character.species)
                Row(title: "Gender", value: store.character.gender.title)
                Row(title: "Origin", value: store.character.originName)
                Row(title: "Last known location", value: store.character.locationName)
                Row(title: "Episodes", value: "\(store.character.episodeCount)")
            }
        }
    }
}

extension CharacterDetailView {
    private struct Row: View {
        let title: String
        let value: String

        var body: some View {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 16)

                Text(value)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.trailing)
            }
            .accessibilityElement(children: .combine)
        }
    }
}

#Preview {
    NavigationStack {
        CharacterDetailView(
            store: Store(initialState: CharacterDetail.State(character: .rick)) {
                CharacterDetail()
            }
        )
    }
}
