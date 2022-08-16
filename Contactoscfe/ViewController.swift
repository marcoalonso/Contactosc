//
//  ViewController.swift
//  Contactoscfe
//
//  Created by marco rodriguez on 16/08/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tablaContactos: UITableView!
    
    // MARK: - Variables
    var contactos: [Contacto] = []
    // ["David", "Pablo", "Rogelio", "Rogelio", "Fanny", "Raul"]
    
    func conexion() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tablaContactos.delegate = self
        tablaContactos.dataSource = self
    }
    
    @IBAction func nuevoContactoButton(_ sender: UIBarButtonItem) {
    
        //Agregar alerta
        let alerta = UIAlertController(title: "Agregar contacto", message: "Nuevo", preferredStyle: .alert)
        
        //Agregar TextField a la alerta
        alerta.addTextField { nombreTF in
            nombreTF.placeholder = "Nombre"
            nombreTF.textColor = .blue
            nombreTF.font = UIFont(name: "Avenir", size: 22)
        }
        
        alerta.addTextField { telefonoTF in
            telefonoTF.placeholder = "Telefono"
            telefonoTF.textColor = .blue
            telefonoTF.font = UIFont(name: "Avenir", size: 20)
            telefonoTF.keyboardType = .numberPad
        }
        
        alerta.addTextField { direccionTF in
            direccionTF.placeholder = "Direccion"
            direccionTF.textColor = .blue
            direccionTF.font = UIFont(name: "Avenir", size: 18)
        }
        
        alerta.addTextField { emailTF in
            emailTF.placeholder = "Email"
            emailTF.textColor = .blue
            emailTF.font = UIFont(name: "Avenir", size: 18)
            emailTF.keyboardType = .emailAddress
        }
        
        
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { _ in
            //1.- Extraer los atributos p crear el nuevo contacto
            guard let nombreAlerta = alerta.textFields?[0].text else { return }
            guard let telefonoAlerta = Int64(alerta.textFields?[1].text ?? "0") else { return }
            guard let direccionAlerta = alerta.textFields?[2].text else { return }
            guard let emailAlerta = alerta.textFields?[3].text else { return }
            let imageTemporal = UIImageView(image: UIImage(named: "emoji"))
            
            //2.- Crear el nuevo contacto
            let contexto = self.conexion()
            let nuevoContacto = Contacto(context: contexto)
            nuevoContacto.nombre = nombreAlerta
            nuevoContacto.telefono = telefonoAlerta
            nuevoContacto.direccion = direccionAlerta
            nuevoContacto.email = emailAlerta
            nuevoContacto.imagen = imageTemporal.image?.pngData()
            
            //3.- guardar contexto
            self.contactos.append(nuevoContacto)
            self.guardarContexto()
            
            //4.- Actualizar UI (agregar al array y actualizar tabla)
            self.tablaContactos.reloadData()
        }
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        alerta.addAction(accionAceptar)
        alerta.addAction(accionCancelar)
        present(alerta, animated: true, completion: nil)
    }
    
    func guardarContexto(){
        //try? self.conexion().save()
        let contexto = conexion()
        do {
            try contexto.save()
        } catch  {
            print("Error al guardar en la bd", error.localizedDescription)
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaContactos.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        celda.textLabel?.text = contactos[indexPath.row].nombre
        celda.detailTextLabel?.text = "\(contactos[indexPath.row].telefono)"
        return celda
    }
    
    
}
