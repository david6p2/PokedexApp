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
    private var currentPage = 1
    private var nextPage: URL?
    private var previousPage: URL?
    private var total = 0
    private var isFetchInProgress = false
    
    var dataLoader: APILoader
    
    init(loader: APILoader = DataLoader()) {
        self.dataLoader = loader
    }
    
    var totalCount: Int {
      return total
    }
    
    func fetchPokemons(_ completion: @escaping ([IndexPath]?) -> Void) {
        // Just one request at a time
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        dataLoader.getMyPokemons(with: currentPage){ [weak self] (result) in
            switch result {
            case .success(let pokemonsResponse):
                self?.isFetchInProgress = false
                self?.currentPage += 1
                
                self?.pokemons.append(contentsOf: pokemonsResponse.results)
                self?.total = pokemonsResponse.count
                self?.nextPage = pokemonsResponse.next
                self?.previousPage = pokemonsResponse.previous
                
                if self?.currentPage ?? 0 > 1 {
                    let indexPathsToReload = self?.calculateIndexPathsToReload(from: pokemonsResponse.results)
                    completion(indexPathsToReload)
                } else {
                    completion(.none)
                }
                
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    // This utility calculates the index paths for the last page of pokemons received from the API.
    // You'll use this to refresh only the content that's changed, instead of reloading the whole table view.
    private func calculateIndexPathsToReload(from newPokemons: [Pokemon]) -> [IndexPath] {
      let startIndex = pokemons.count - newPokemons.count
      let endIndex = startIndex + newPokemons.count
      return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    func startOperations(for pokemon: Pokemon, at indexPath: IndexPath, completion: @escaping () -> Void) {
        switch (pokemon.downloadState) {
        case .new:
            startDownload(for: pokemon, at: indexPath, completion: completion)
        default:
           print("do nothing")
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
