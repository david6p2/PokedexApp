//
//  PokemonNameTableViewCell.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/27/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import UIKit

class PokemonNameTableViewCell: UITableViewCell {

    @IBOutlet var pokemonNameLabel: UILabel!
    
    var pokemonName: String? {
        didSet {
            guard let pokemonName = pokemonName else { return }
            pokemonNameLabel.text = pokemonName.capitalized
        }
    }
}
