//
//  PokemonDetailViewController.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/26/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import UIKit

class PokemonDetailViewController: UIViewController {
    
    var pokemon: Pokemon?
    private let pokemonNameCellId = "PokemonNameCell"
    private let pokemonTypeCellId = "PokemonTypeCell"
    private let pokemonDescriptionCellId = "PokemonDescriptionCell"
    private let pokemonSegmentedControlCellId = "PokemonSegmentedControlCell"
    private let pokemonContainerViewCellId = "PokemonContainerViewCell"
    private let pokemonDefaultViewCellId = "PokemonDefaultViewCell"
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonDetailTableView: PokemonDetailUITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pokemonDetailTableView.delegate = self
        pokemonDetailTableView.dataSource = self
        self.view.backgroundColor = self.generateBackgroundColorFromType((pokemon?.types.last)!)
        if let pokemon = pokemon,
            let pokemonImageData = pokemon.image {
            pokemonImageView.image = UIImage(data: pokemonImageData)
        }
    }
    
    func generateBackgroundColorFromType(_ type:Pokemon.PokemonType) -> UIColor? {
        switch type.type.name {
        case "normal":
            return UIColor(red: 154/255, green: 157/255, blue: 161/255, alpha: 1)
        case "fighting":
            return UIColor(red: 217/255, green: 66/255, blue: 86/255, alpha: 1)
        case "flying":
            return UIColor(red: 155/255, green: 180/255, blue: 232/255, alpha: 1)
        case "poison":
            return UIColor(red: 181/255, green: 99/255, blue: 206/255, alpha: 1)
        case "ground":
            return UIColor(red: 215/255, green: 133/255, blue: 85/255, alpha: 1)
        case "rock":
            return UIColor(red: 206/255, green: 193/255, blue: 140/255, alpha: 1)
        case "bug":
            return UIColor(red: 157/255, green: 193/255, blue: 48/255, alpha: 1)
        case "ghost":
            return UIColor(red: 105/255, green: 112/255, blue: 197/255, alpha: 1)
        case "steel":
            return UIColor(red: 85/255, green: 150/255, blue: 164/255, alpha: 1)
        case "fire":
            return UIColor(red: 248/255, green: 165/255, blue: 79/255, alpha: 1)
        case "water":
            return UIColor(red: 85/255, green: 158/255, blue: 223/255, alpha: 1)
        case "grass":
            return UIColor(red: 93/255, green: 190/255, blue: 98/255, alpha: 1)
        case "electric":
            return UIColor(red: 237/255, green: 213/255, blue: 63/255, alpha: 1)
        case "psychic":
            return UIColor(red: 248/255, green: 124/255, blue: 122/255, alpha: 1)
        case "ice":
            return UIColor(red: 126/255, green: 212/255, blue: 201/255, alpha: 1)
        case "dragon":
            return UIColor(red: 7/255, green: 115/255, blue: 199/255, alpha: 1)
        case "dark":
            return UIColor(red: 95/255, green: 96/255, blue: 109/255, alpha: 1)
        case "fairy":
            return UIColor(red: 239/255, green: 151/255, blue: 230/255, alpha: 1)
        case "shadow":
            return .darkGray
        default:
            return .gray
        }
    }
}

extension PokemonDetailViewController: UITableViewDelegate { }

extension PokemonDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = pokemonDetailTableView.dequeueReusableCell(withIdentifier: pokemonNameCellId,
                                                                  for: indexPath) as! PokemonNameTableViewCell
            cell.pokemonName = pokemon?.name
            return cell
        case 1:
            let cell = pokemonDetailTableView.dequeueReusableCell(withIdentifier: pokemonTypeCellId,
                                                                  for: indexPath) as! PokemonTypeTableViewCell
            cell.pokemonTypes = pokemon?.types
            return cell
        case 2:
            let cell = pokemonDetailTableView.dequeueReusableCell(withIdentifier: pokemonDescriptionCellId,
                                                                  for: indexPath)
            return cell
        default:
            let cell = pokemonDetailTableView.dequeueReusableCell(withIdentifier: pokemonDefaultViewCellId,
                                                                  for: indexPath)
            return cell
        }
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

class PokemonDetailUITableView: UITableView {
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: self.frame.width/8)
    }
}
