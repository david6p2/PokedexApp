//
//  Pokemons.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/20/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import Foundation

struct PagedPokemons: Codable {
    struct BriefPokemon: Codable {
        let name: String
        let url: URL
    }
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [BriefPokemon]
}

struct PagedCompletePokemons: Codable {
    struct BriefPokemon: Codable {
        let name: String
        let url: URL
    }
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [Pokemon]
}
