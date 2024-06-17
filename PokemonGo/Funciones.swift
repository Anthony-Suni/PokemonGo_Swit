//
//  Funciones.swift
//  PokemonGo
//
//  Created by Jonathan on 17/06/24.
//

import UIKit
import CoreData

func crearPokemon(xnombre: String, ximagenNombre: String) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let pokemon = Pokemon(context: context)
    pokemon.nombre = xnombre
    pokemon.imagenNombre = ximagenNombre
    pokemon.atrapado = false // Nuevo Pokémon creado, inicialmente no atrapado
    
    // Guardar el contexto
    do {
        try context.save()
    } catch {
        print("Error al guardar Pokémon: \(error)")
    }
}

func agregarPokemons() {
    crearPokemon(xnombre: "Mew", ximagenNombre: "mew")
    crearPokemon(xnombre: "Meowth", ximagenNombre: "meowth")
    crearPokemon(xnombre: "Abra", ximagenNombre: "abra")
    crearPokemon(xnombre: "Bullbasaur", ximagenNombre: "bullbasaur")
    crearPokemon(xnombre: "Dratini", ximagenNombre: "dratini")
    crearPokemon(xnombre: "Eevee", ximagenNombre: "eevee")
    crearPokemon(xnombre: "Mankey", ximagenNombre: "mankey")
    crearPokemon(xnombre: "Pikachu", ximagenNombre: "pikachu-2")
    crearPokemon(xnombre: "Psyduck", ximagenNombre: "psyduck")
    crearPokemon(xnombre: "Rattata", ximagenNombre: "rattata")
    crearPokemon(xnombre: "Snorlax", ximagenNombre: "snorlax")
    crearPokemon(xnombre: "Squirtle", ximagenNombre: "squirtle")
    crearPokemon(xnombre: "Venonat", ximagenNombre: "venonat")
    crearPokemon(xnombre: "Weedle", ximagenNombre: "weedle")
    crearPokemon(xnombre: "Zubat", ximagenNombre: "zubat")
}


func obtenerPokemon() -> [Pokemon] {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    do {
        let pokemons = try context.fetch(Pokemon.fetchRequest()) as! [Pokemon]
        if pokemons.isEmpty {
            agregarPokemons()
            return obtenerPokemon()
        }
        return pokemons
    } catch {
        print("Error al obtener Pokémon: \(error)")
        return []
    }
}

func obtenerPokemonsAtrapados() -> [Pokemon] {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "atrapado == %@", NSNumber(value: true))
    
    do {
        let pokemons = try context.fetch(fetchRequest)
        return pokemons
    } catch {
        print("Error al obtener Pokémon atrapados: \(error)")
        return []
    }
}


func obtenerPokemonsNoAtrapados() -> [Pokemon] {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "atrapado == %@", NSNumber(value: false))
    
    do {
        let pokemons = try context.fetch(fetchRequest)
        return pokemons
    } catch {
        print("Error al obtener Pokémon no atrapados: \(error)")
        return []
    }
}
