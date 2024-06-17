//
//  ViewController.swift
//  PokemonGo
//
//  Created by Jonathan on 17/06/24.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var ubicacion = CLLocationManager()
    var contActualizaciones = 0
    var pokemons:[Pokemon] = []
    
    @IBAction func centrarTapped(_ sender: Any) {
        if let coord = ubicacion.location?.coordinate {
                let region = MKCoordinateRegion(center: coord,
                                                latitudinalMeters: 1000,
                                                longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
                contActualizaciones += 1
            } else {

            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ubicacion.delegate = self
        pokemons = obtenerPokemon()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            setup()
        }else{
            ubicacion.requestWhenInUseAuthorization()

        }
    }
    
    func setup() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        ubicacion.startUpdatingLocation()
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            if let coord = self.ubicacion.location?.coordinate {
                let randomIndex = Int(arc4random_uniform(UInt32(self.pokemons.count)))
                let pokemon = self.pokemons[randomIndex]
                
                let pin = PokePin(coord: coord, pokemon: pokemon)
                
                let randomLat = (Double(arc4random_uniform(200)) - 100.0) / 5000.0
                let randomLon = (Double(arc4random_uniform(200)) - 100.0) / 5000.0
                
                pin.coordinate.latitude += randomLat
                pin.coordinate.longitude += randomLon
                
                self.mapView.addAnnotation(pin)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            setup()
        }
    }


    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if contActualizaciones < 1 {
            let region = MKCoordinateRegion.init(center:
            ubicacion.location!.coordinate,latitudinalMeters:1000,
            longitudinalMeters:1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        } else {
            ubicacion.stopUpdatingLocation()
        }
        //print( "Ubicacion actualizada")
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            // Si la anotación es la ubicación del usuario, usar un pin personalizado
            let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pinView.image = UIImage(named: "player")
            var frame = pinView.frame
            frame.size = CGSize(width: 50, height: 50)
            pinView.frame = frame
            return pinView
        }
        
        guard let pokePin = annotation as? PokePin else {
            return nil
        }
        
        let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        if let imagenNombre = pokePin.pokemon.imagenNombre, let image = UIImage(named: imagenNombre) {
            pinView.image = image
        } else {
            // Si no se puede obtener la imagen, usar una imagen por defecto o manejar el error según tu lógica
            pinView.image = UIImage(named: "defaultPokemonImage")
        }
        
        var frame = pinView.frame
        frame.size = CGSize(width: 50, height: 50)
        pinView.frame = frame
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        guard let pokePin = view.annotation as? PokePin else {
            print("No se pudo obtener el PokePin desde la anotación.")
            return
        }
        
        let region = MKCoordinateRegion(center: pokePin.coordinate,
                                        latitudinalMeters: 200,
                                        longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        
        // Verificar si el Pokémon ya está atrapado
        if pokePin.pokemon.atrapado {
            // Mostrar alerta de confirmación
            let alertaVC = UIAlertController(title: "¡Atención!",
                                              message: "Ya tienes a este Pokémon, ¿aún así deseas capturarlo?",
                                              preferredStyle: .alert)
            
            let capturarAccion = UIAlertAction(title: "Sí", style: .default) { (_) in
                self.capturarPokemon(pokemon: pokePin.pokemon, view: view)
            }
            alertaVC.addAction(capturarAccion)
            
            let cancelarAccion = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertaVC.addAction(cancelarAccion)
            
            present(alertaVC, animated: true, completion: nil)
        } else {
            // El Pokémon no está atrapado, proceder a la captura
            capturarPokemon(pokemon: pokePin.pokemon, view: view)
        }
    }

    func capturarPokemon(pokemon: Pokemon, view: MKAnnotationView) {
        if let coord = self.ubicacion.location?.coordinate {
            let mapPoint = MKMapPoint(coord)
            let mapRect = mapView.visibleMapRect
            
            if mapRect.contains(mapPoint) {
                print("¡Puede atrapar el pokemon!")
                pokemon.atrapado = true
                pokemon.pokemonn = (pokemon.pokemonn ?? 0) + 1  // Incrementar el contador
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                mapView.removeAnnotation(view.annotation!) // Remover la anotación del mapa
                
                // Mensaje al atrapar pokemon
                let alertaVC = UIAlertController(title: "¡Felicidades!",
                                                  message: "¡Atrapaste al pokemón (\(pokemon.nombre!))!",
                                                  preferredStyle: .alert)
                
                let pokedexAccion = UIAlertAction(title: "Ver Pokédex",
                                                  style: .default,
                                                  handler: { (action) in
                                                      self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
                                                  })
                alertaVC.addAction(pokedexAccion)
                
                let okAccion = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil)
                alertaVC.addAction(okAccion)
                
                self.present(alertaVC, animated: true, completion: nil)
                
            } else {
                print("No se puede atrapar el pokemon")
                let alertaVC = UIAlertController(title: "¡Oops, está muy lejos!",
                                                 message: "No puedes atrapar al pokemón (\(pokemon.nombre!)). Acércate más.",
                                                 preferredStyle: .alert)
                let okAccion = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertaVC.addAction(okAccion)
                self.present(alertaVC, animated: true, completion: nil)
            }
        }
    }


}

