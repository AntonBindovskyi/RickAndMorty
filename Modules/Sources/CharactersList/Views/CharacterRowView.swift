//
//  CharacterRowView.swift
//  Modules
//
//  Created by Anton Bindovskyi on 02.09.2026.
//

import Models
import Nuke
import NukeUI
import SwiftUI

struct CharacterRowView: View {
    
    enum Layout {
        static let imageSize: CGFloat = 60
        static let avatarCornerRadius: CGFloat = 8
    }

    let character: Character

    var body: some View {
        HStack(spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .lineLimit(1)

                Text("\(character.species): \(character.status.title)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    private var avatar: some View {
        LazyImage(
            request: ImageRequest(
                url: character.imageURL,
                processors: [
                    ImageProcessors.Resize(
                        width: Layout.imageSize,
                        unit: .points
                    )
                ]
            )
        ) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
            } else if state.error != nil {
                Image(systemName: "person.slash")
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
            }
        }
        .frame(width: Layout.imageSize, height: Layout.imageSize)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: Layout.avatarCornerRadius))
    }
}

#Preview("Row") {
    List {
        CharacterRowView(character: .rick)
        CharacterRowView(character: .morty)
        CharacterRowView(character: .smith)
    }
    .listStyle(.plain)
}
