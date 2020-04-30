//
//  PokemonTableViewCell.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/21/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import UIKit

class PokemonTableViewCell: UITableViewCell {
    
    @IBOutlet var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var pokemonImageView: UIImageView!
    @IBOutlet var pokemonTitleLabel: UILabel!
    @IBOutlet var pokemonSubtitleLabel: UILabel!
    @IBOutlet var typesView: UIStackView!
    @IBOutlet var typeImageView: UIImageView!
    
    private let placeholder = UIImage(named: "Placeholder")!.pngData()!
    private let circleImageName = ".circle"
    
    override func prepareForReuse() {
      super.prepareForReuse()
      
      configure(with: .none)
    }
    
    func configure(with pokemon: Pokemon?) {
        if let pokemon = pokemon {
            selectedBackgroundView = self.applySelectedColorToCell()
            
            pokemonTitleLabel?.alpha = 1
            pokemonSubtitleLabel?.alpha = 1
            pokemonTitleLabel?.text = pokemon.name.capitalized
            pokemonSubtitleLabel?.text = String(format: "#%03d", pokemon.id)
            pokemonImageView.image = UIImage(data: pokemon.image ?? placeholder)
            
            typesView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            typesView = self.generateTypesViewForCell(self, withTypes: pokemon.types)
            
            switch pokemon.downloadState {
            case .failed:
                imageActivityIndicator.stopAnimating()
                pokemonTitleLabel?.text = "Failed to load"
            case .new:
                imageActivityIndicator.startAnimating()
                // after this the controller will fire the image request
            case .downloaded:
                imageActivityIndicator.stopAnimating()
            }
        } else {
            pokemonTitleLabel?.alpha = 1
            pokemonTitleLabel?.text = "Loading..."
            pokemonSubtitleLabel?.alpha = 0
            imageActivityIndicator.startAnimating()
            pokemonImageView.image = nil
            typesView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
    }
    
    func generateTypesViewForCell(_ cell:PokemonTableViewCell, withTypes types:[Pokemon.PokemonType]) -> UIStackView? {
        let stackView = cell.typesView
        types.forEach { (pokemonType) in
            let imageName = pokemonType.type.name.capitalized + circleImageName
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            stackView?.addArrangedSubview(imageView)
        }
        return stackView
    }
    
    func applySelectedColorToCell() -> UIView {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.init(red: 156.0/255.0,
                                                      green: 210.0/255.0,
                                                      blue: 239.0/255.0,
                                                      alpha: 1.0)
        return backgroundView
    }
    
}

import SwiftUI
struct PokemonTableViewCell_Previews: PreviewProvider {

    static var previews: some View {
        PokemonTableViewCell_Previews()
            .previewLayout(.fixed(width: 375, height: 75))
    }

}

extension PokemonTableViewCell_Previews: UIViewRepresentable {
    typealias UIViewType = PokemonTableViewCell

    func makeUIView(context: UIViewRepresentableContext<PokemonTableViewCell_Previews>) -> PokemonTableViewCell {
        let nib = UINib(nibName: "PokemonTableViewCell", bundle: nil)
        let view = nib.instantiate(withOwner: nil).first as! PokemonTableViewCell

        view.pokemonImageView.image = #imageLiteral(resourceName: "001")
        view.typeImageView.image =  #imageLiteral(resourceName: "Grass.circle")
        view.pokemonTitleLabel.text = "Bulbasaur"
        view.pokemonSubtitleLabel.text = "#001"

        return view
    }

    func updateUIView(_ uiView: PokemonTableViewCell,
                      context: UIViewRepresentableContext<PokemonTableViewCell_Previews>) {}
}
