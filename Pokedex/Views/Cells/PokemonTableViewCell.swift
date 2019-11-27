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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
