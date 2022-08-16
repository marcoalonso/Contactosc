//
//  EditarViewController.swift
//  Contactoscfe
//
//  Created by marco rodriguez on 16/08/22.
//

import UIKit

class EditarViewController: UIViewController {
    
    var recibirContacto: Contacto?
    
    @IBOutlet weak var emailEditar: UITextField!
    @IBOutlet weak var direccionEditar: UITextField!
    @IBOutlet weak var telefonoEditar: UITextField!
    @IBOutlet weak var nombreEditar: UITextField!
    @IBOutlet weak var imagenEditar: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        mostrarContactoEditar()
    }
    
    func mostrarContactoEditar(){
        nombreEditar.text = recibirContacto?.nombre
        telefonoEditar.text = "\(recibirContacto?.telefono ?? 0)"
        direccionEditar.text = recibirContacto?.direccion
        emailEditar.text = recibirContacto?.email
        imagenEditar.image = UIImage(data: (recibirContacto?.imagen!)!)
        
    }
    
    @IBAction func guardarButton(_ sender: Any) {
        
    }
    
    @IBAction func cancelarBtn(_ sender: Any) {
        
    }
    
   

}
