//
//  PokemonOperations.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/25/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import Foundation
import UIKit

class PendingOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

class ImageDownloader: Operation {
    var pokemon: Pokemon
    
    init(_ pokemon: Pokemon) {
        self.pokemon = pokemon
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        guard let imageData = try? Data(contentsOf: pokemon.imageURL) else { return }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            self.pokemon.image = UIImage(data:imageData)?.pngData()
            self.pokemon.downloadState = .downloaded
        } else {
            self.pokemon.downloadState = .failed
            self.pokemon.image = UIImage(named: "Failed")?.pngData()
        }
    }
}
