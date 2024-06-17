//
//  PokedexViewController.swift
//  PokemonGo
//
//  Created by Jonathan on 17/06/24.
//

import UIKit
import CoreData

class PokedexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func mapTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    var pokemonsAtrapados: [Pokemon] = []
    var pokemonsNoAtrapados: [Pokemon] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self

            cargarPokemons()
            
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "pokemonCell")

        }

        func cargarPokemons() {
            pokemonsAtrapados = obtenerPokemonsAtrapados()
            pokemonsNoAtrapados = obtenerPokemonsNoAtrapados()

            // Si no hay Pokémon, agregar algunos inicialmente
            if pokemonsAtrapados.isEmpty && pokemonsNoAtrapados.isEmpty {
                agregarPokemons()
                pokemonsAtrapados = obtenerPokemonsAtrapados()
                pokemonsNoAtrapados = obtenerPokemonsNoAtrapados()
            }

            tableView.reloadData()
        }

        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            if section == 0 {
                return "Atrapados"
            } else {
                return "No Atrapados"
            }
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            return 2
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if section == 0 {
                return pokemonsAtrapados.count
            } else {
                return pokemonsNoAtrapados.count
            }
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath)
            var pokemon: Pokemon

            if indexPath.section == 0 {
                pokemon = pokemonsAtrapados[indexPath.row]
            } else {
                pokemon = pokemonsNoAtrapados[indexPath.row]
            }

            cell.textLabel?.text = pokemon.nombre
            if let imageName = pokemon.imagenNombre {
                cell.imageView?.image = UIImage(named: imageName)
            }

            return cell
        }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if indexPath.section == 0 {
                    let pokemonEliminado = pokemonsAtrapados.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)

                    // Aquí llamamos a la función para eliminar el Pokémon de CoreData
                    eliminarPokemon(pokemon: pokemonEliminado)
                }
            }
        }

        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            if indexPath.section == 0 {
                return .delete
            } else {
                return .none // Sin estilo de edición para la sección de Pokémon no atrapados
            }
        }
    
    
    // Función para eliminar un Pokémon de CoreData
        func eliminarPokemon(pokemon: Pokemon) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(pokemon)

            do {
                try managedContext.save()
                print("Pokemon eliminado correctamente")
            } catch let error as NSError {
                print("Error al eliminar el Pokémon: \(error.localizedDescription)")
            }
        }

    }
