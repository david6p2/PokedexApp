//
//  Pokemon.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/20/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import Foundation
import UIKit

enum PokemonRecordState: String,  Codable {
  case new, downloaded, failed
}

struct Pokemon: Codable {
    
    enum CodingKeys: CodingKey {
        case id, order, baseExperience, name, types, moves, height, weight
    }
    
    struct BriefType: Codable {
        let name: String
        let url: URL
    }
    struct PokemonType: Codable {
        let slot: Int
        let type: BriefType
    }
    struct BriefMove: Codable {
        let name: String
        let url: URL
    }
    struct PokemonMove: Codable {
        let move: BriefMove
    }
    let id: Int
    let order: Int
    let baseExperience: Int
    let name: String
    let types: [Pokemon.PokemonType]
    let moves: [Pokemon.PokemonMove]
    let height: Int
    let weight: Int
    var downloadState = PokemonRecordState.new
    var image: Data? = UIImage(named: "Placeholder")?.pngData()
    var imageURL: URL {
        get {
            let baseURL = "https://assets.pokemon.com/assets/cms2/img/pokedex/detail/"
            let idURL = String(format: "%03d", id)
            return URL(string: baseURL + idURL + ".png")!
        }
    }
    
    // Initializer used mainly for Previews and tests
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        baseExperience = 10
        order = id
        types = .init()
        moves = .init()
        height = 0
        weight = 0
    }
}
