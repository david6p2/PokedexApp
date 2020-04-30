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
    private let cellIdentifier = "PokemonCell"
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
        pokemonsTableView.prefetchDataSource = self
        tableActivityIndicator.startAnimating()
        loadingLabel.isHidden = false
        controller.fetchPokemons { _ in
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
            destination.pokemon = controller.pokemons[pokemonIndex]
        }
    }
}

extension PokemonListViewController: UITableViewDelegate { }

extension PokemonListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath) as! PokemonTableViewCell
        if isLoadingCell(for: indexPath) {
            cell.configure(with: .none)
        } else {
            let pokemon = controller.pokemons[indexPath.row]
            cell.configure(with: pokemon)
            if pokemon.downloadState == .new {
                controller.startOperations(for: pokemon, at: indexPath) { [weak self] in
                    self?.pokemonsTableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        }
        
        return cell
    }
}

extension PokemonListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            controller.fetchPokemons { (newIndexPathsToReload) in
                guard let newIndexPathsToReload = newIndexPathsToReload else {
                    DispatchQueue.main.async { [weak self] in
                        self?.loadingLabel.isHidden = true
                        self?.tableActivityIndicator.stopAnimating()
                        self?.pokemonsTableView.reloadData()
                        
                    }
                    return
                }
                let indexPathsToReload = self.visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
                DispatchQueue.main.async { [weak self] in
                    self?.pokemonsTableView.reloadRows(at: indexPathsToReload, with: .automatic)
                }
            }
        }
    }
}

private extension PokemonListViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= controller.pokemons.count
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = pokemonsTableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}
