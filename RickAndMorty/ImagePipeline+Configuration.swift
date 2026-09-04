//
//  ImagePipeline+Configuration.swift
//  RickAndMorty
//
//  Created by Anton Bindovskyi on 03.09.2026.
//

import Nuke

extension ImagePipeline {
    nonisolated static let charactersPipeline: ImagePipeline = {
        var configuration = ImagePipeline.Configuration.withDataCache(
            name: "com.rickandmorty.images",
            sizeLimit: 200 * 1024 * 1024
        )

        configuration.imageCache = ImageCache(costLimit: 50 * 1024 * 1024)
        configuration.dataLoadingQueue.maxConcurrentOperationCount = 2
        configuration.isRateLimiterEnabled = true

        return ImagePipeline(configuration: configuration)
    }()
}
