//
//  MapaViewController.swift
//  Contactoscfe
//
//  Created by Marco Alonso Rodriguez on 11/11/22.
//

import UIKit
import MapKit

class MapaViewController: UIViewController {

    var direccionUser: String?
    
    @IBOutlet weak var mapa: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Debug: direccion\(direccionUser ?? "")")
        buscarLugar()
    }
    
    func buscarLugar(){
        self.mapa.removeAnnotations(mapa.annotations)
        let geocoder = CLGeocoder()  //para convertir entre un lugar y coordenadas
        if direccionUser != nil {
            if let direccion = direccionUser {
                geocoder.geocodeAddressString(direccion) { (lugares: [CLPlacemark]?, error: Error?) in
                    //validar si hubo error
                    if error != nil {
                        print("Debug: Error al encontrar lugar \(error!.localizedDescription)")
                        self.showAlert("ERROR", "No se encotro un lugar con esa direccion, regresar y probar con otra.")
                    }
                    print("Debug: Lugares encontrados \(lugares?.count)")
                    //si hubo algun lugar con la busqueda
                    if let lugar = lugares?.first {
                        //crear una anotacion
                        let anotacion = MKPointAnnotation()
                        anotacion.coordinate = lugar.location!.coordinate
                        anotacion.title = direccion
                        anotacion.subtitle = "Lat: \(lugar.location!.coordinate.longitude) , Lon: \(lugar.location!.coordinate.longitude)"
                        
                        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                        let region = MKCoordinateRegion(center: anotacion.coordinate, span: span)
                        
                        self.mapa.setRegion(region, animated: true)
                        self.mapa.addAnnotation(anotacion)
                    }
                    
                }
            }
        }
    }

    func showAlert(_ titulo: String, _ mensaje: String){
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Regresar", style: .default) { _ in
            //Do something
            self.navigationController?.popToRootViewController(animated: true)
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }

}
