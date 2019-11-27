//
//  PokemonDetailViewController.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/26/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import UIKit

class PokemonDetailViewController: UIViewController {
    
    @IBOutlet var pokemonNameLabel: UILabel!
    
    var pokemonName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pokemonNameLabel.text = pokemonName
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
