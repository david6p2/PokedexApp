//
//  PokemonListController.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/25/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import Foundation

class PokemonListController {
    private let pendingOperations = PendingOperations()
    var pokemons: [Pokemon] = .init()
    var dataLoader: APILoader
    
    init(loader: APILoader = DataLoader()) {
        self.dataLoader = loader
    }
    
    func fetchPokemons(completion: @escaping () -> Void) {
        dataLoader.getMyPokemons { [weak self] (result) in
            switch result {
            case .success(let pokemons):
                self?.pokemons = pokemons
                completion()
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    func startOperations(for pokemon: Pokemon, at indexPath: IndexPath, completion: @escaping () -> Void) {
        switch (pokemon.downloadState) {
        case .new:
            startDownload(for: pokemon, at: indexPath, completion: completion)
        default:
            NSLog("do nothing")
        }
    }
    
    private func startDownload(for pokemon: Pokemon, at indexPath: IndexPath, completion: @escaping () -> Void) {
        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        let downloader = ImageDownloader(pokemon)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pokemons[indexPath.row] = downloader.pokemon
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                completion()
            }
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
}
