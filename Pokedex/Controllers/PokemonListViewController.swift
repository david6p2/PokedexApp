//
//  ViewController.swift
//  Pokedex
//
//  Created by David Andres Cespedes on 11/20/19.
//  Copyright © 2019 David Andres Cespedes. All rights reserved.
//

import UIKit

import SwiftUI
struct PokemonListViewController_Previews: PreviewProvider {
    static var previews: some View {
       PokemonListViewController_Previews()
//        .preferredColorScheme(.dark)
    }
}

extension PokemonListViewController_Previews: UIViewControllerRepresentable {
    typealias UIViewControllerType = PokemonListViewController

    func makeUIViewController(context: UIViewControllerRepresentableContext<PokemonListViewController_Previews>) -> PokemonListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "PokemonListViewController") as! PokemonListViewController

        vc.controller.dataLoader = MockDataLoader()
        return vc
    }

    func updateUIViewController(_ uiViewController: PokemonListViewController,
                                context: UIViewControllerRepresentableContext<PokemonListViewController_Previews>) {}
}

class PokemonListViewController: UIViewController {
    private let placeholder = UIImage(named: "Placeholder")!.pngData()!
    private let cellIdentifier = "PokemonCell"
    private let circleImageName = ".circle"
    private let pokemonDetailSegueIdentifier = "PokemonDetailSegue"
    
    @IBOutlet private weak var tableActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet private weak var pokemonsTableView: UITableView!
    
    var controller: PokemonListController = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pokemonsTableView.delegate = self
        pokemonsTableView.dataSource = self
        pokemonsTableView.register(UINib.init(nibName: "PokemonTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableActivityIndicator.startAnimating()
        loadingLabel.isHidden = false
        controller.fetchPokemons {
            DispatchQueue.main.async { [weak self] in
                self?.loadingLabel.isHidden = true
                self?.tableActivityIndicator.stopAnimating()
                self?.pokemonsTableView.reloadData()
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == pokemonDetailSegueIdentifier,
            let destination = segue.destination as? PokemonDetailViewController,
            let pokemonIndex = pokemonsTableView.indexPathForSelectedRow?.row {
            destination.pokemonName = controller.pokemons[pokemonIndex].name
        }
    }
}

extension PokemonListViewController: UITableViewDelegate { }

extension PokemonListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath) as! PokemonTableViewCell
        cell.selectedBackgroundView = self.applySelectedColorToCell()
        
        let pokemon = controller.pokemons[indexPath.row]
        
        cell.pokemonTitleLabel?.text = pokemon.name.capitalized
        cell.pokemonSubtitleLabel?.text = String(format: "#%03d", pokemon.id)
        cell.pokemonImageView.image = UIImage(data: pokemon.image ?? placeholder)
        
        cell.typesView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cell.typesView = self.generateTypesViewForCell(cell, withTypes: pokemon.types)
        
        switch pokemon.downloadState {
        case .failed:
            cell.imageActivityIndicator.stopAnimating()
            cell.pokemonTitleLabel?.text = "Failed to load"
        case .new:
            cell.imageActivityIndicator.startAnimating()
            controller.startOperations(for: pokemon, at: indexPath) { [weak self] in
                self?.pokemonsTableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .downloaded:
            cell.imageActivityIndicator.stopAnimating()
        }
        return cell
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

