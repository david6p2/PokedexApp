//
//  PokemonMove.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/21/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import Foundation

struct PokemonMove: Codable {
    struct MoveType: Codable {
        let name: String
        let url: URL
    }
    
    let id: Int
    let name: String
    let power: Int
    let accuracy: Int
    let pp: Int
    let type: MoveType
}
