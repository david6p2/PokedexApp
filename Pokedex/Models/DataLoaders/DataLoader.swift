//
//  DataLoader.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/20/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import Foundation

protocol APILoader {
    func getMyPokemons(_ handler: @escaping (Result<[Pokemon], Error>) -> Void)
}

struct MockDataLoader: APILoader {
    
    func getMyPokemons(_ handler: @escaping (Result<[Pokemon], Error>) -> Void) {
        let pokemons: [Pokemon] = [
        .init(id: 1, name: "bulbasaur"),
        .init(id: 2, name: "ivasaur"),
        .init(id: 3, name: "venusarur"),
        .init(id: 4, name: "charmander"),
        .init(id: 5, name: "charmeleon")
        ]
        handler(.success(pokemons))
    }
}

class DataLoader: APILoader {
    
    let baseEndPoint = "https://pokeapi.co/api/v2/"
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask? = nil
    
    /// Looad PagedPokemons form a local JSON File
    private func loadJSON(fileName: String) -> PagedPokemons? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(PagedPokemons.self, from: data)
                return jsonData
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /// Looad PagedPokemons form the internet using the baseEndPoint
    private func loadPagedPokemons(fromEndpoint: String,
                           withLimit limit: Int,
                           handler: @escaping (Result<PagedPokemons, Error>) -> Void) {
        dataTask?.cancel()
        
        var urlComponents = URLComponents(string: baseEndPoint+fromEndpoint)
        urlComponents?.query = "limit=\(limit)"
        
        guard let url = urlComponents?.url else { return }
        
        self.dataTask = defaultSession.dataTask(with: url,
                                           completionHandler: { (data, response, error) in
                                            defer { self.dataTask = nil }
                                            
                                            guard let response = response as? HTTPURLResponse,
                                                response.statusCode == 200,
                                                let data = data
                                                else {
                                                    handler(Result.failure(error ?? NSError()))
                                                    return
                                            }
                                            
                                            guard let decodedResponse = try? JSONDecoder().decode(PagedPokemons.self, from: data) else {
                                                handler(Result.failure(error ?? NSError()))
                                                return
                                            }
                                            handler(Result.success(decodedResponse))
        })
        dataTask?.resume()
    }
    
    /// Looad Pokemon form a local JSON File
    private func loadPokemon(fileName: String) -> Pokemon? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(Pokemon.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    /// Looad Pokemons form the internet using the baseEndPoint
    private func loadPokemon(fromEndpoint: String,
                     withIdOrName pokemonId: String,
                     handler: @escaping (Result<Pokemon, Error>) -> Void) {
        //dataTask?.cancel()
        
        let urlComponents = URLComponents(string: baseEndPoint+fromEndpoint+"/"+pokemonId)
        
        guard let url = urlComponents?.url else { return }
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url,
                         completionHandler: { (data, response, error) in
                            //                                            defer { self.dataTask = nil }
                            
                            guard let response = response as? HTTPURLResponse,
                                response.statusCode == 200,
                                let data = data
                                else {
                                    handler(Result.failure(error ?? NSError()))
                                    return
                            }
                            
                            do {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                let decodedResponse = try decoder.decode(Pokemon.self, from: data)
                                handler(Result.success(decodedResponse))
                            } catch {
                                print(error.localizedDescription)
                                handler(Result.failure(error))
                            }
                            
        }).resume()
    }
    
    public func getPagedPokemons(_ handler: @escaping (Result<PagedPokemons, Error>) -> Void) {
        // Loading from JSON File
//        if let pagedPokemons = self.loadJSON(fileName: "pokemon") {
//            handler(.success(pagedPokemons))
//        } else {
//            handler(.failure(NSError()))
//        }
        
        // Loading from Pokeapi
        self.loadPagedPokemons(fromEndpoint: "pokemon",
                               withLimit: 50) { (result) in
                                switch result {
                                case .success(let pagedPokemons):
                                    handler(.success(pagedPokemons))
                                    break
                                case .failure(let error):
                                    handler(.failure(error))
                                    break
                                }
        }
    }
    
    public func getPokemon(withIdOrName pokemonId: String,
                           handler: @escaping (Result<Pokemon, Error>) -> Void) {
        // Loading from JSON File
//        if let pokemon = self.loadPokemon(fileName: "charizard") {
//            handler(.success(pokemon))
//        } else {
//            handler(.failure(NSError()))
//        }
        
        // Loading from Pokeapi
        self.loadPokemon(fromEndpoint: "pokemon",
                         withIdOrName: pokemonId) { (result) in
                            switch result {
                            case .success(let pokemon):
                                handler(.success(pokemon))
                                break
                            case .failure(let error):
                                handler(.failure(error))
                                break
                            }
        }
    }
    
    public func getMyPokemons(_ handler: @escaping (Result<[Pokemon], Error>) -> Void) {
        self.getPagedPokemons { (result) in
            switch result {
            case .success(let pagedPokemons):
                
                let group = DispatchGroup()
                let myPagedPokemons = pagedPokemons.results
                var pokemons: [Pokemon] = []
                for pagedPokemon in myPagedPokemons {
                    print(pagedPokemon)
                    // Bring Pokemon from url
                    group.enter()
                    self.getPokemon(withIdOrName: pagedPokemon.name) { (pokemonResult) in
                        switch pokemonResult {
                        case .success(let pokemon):
                            pokemons.append(pokemon)
                            break
                        case .failure(let error):
                            print(error.localizedDescription)
                            break
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    handler(.success(pokemons.sorted(by: { $0.id < $1.id })))
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                handler(.failure(NSError()))
                break
            }
        }
    }
}
